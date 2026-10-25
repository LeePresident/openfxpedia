import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_messages.dart';
import '../providers/app_state.dart';
import '../services/exchange_api_source.dart';
import '../services/error_classifier.dart';
import '../services/update_service.dart';
import 'changelog_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.updateService,
    this.packageInfoLoader,
    this.updateAssetNameResolver,
  });

  final UpdateService? updateService;
  final Future<PackageInfo> Function()? packageInfoLoader;
  final String? Function(String version)? updateAssetNameResolver;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<PackageInfo> _pkgInfo;
  late final UpdateService _updateService;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _updateService = widget.updateService ?? UpdateService();
    _pkgInfo = widget.packageInfoLoader?.call() ?? PackageInfo.fromPlatform();
  }

  Future<void> _checkForUpdates(String currentVersion) async {
    final l10n = AppLocalizations.of(context);
    if (!mounted) return;
    setState(() => _checking = true);
    try {
      final latestRelease = await _updateService.fetchLatestStableRelease();
      final latestVersion = latestRelease?.version;
      final current = UpdateService.normalizeVersion(currentVersion);

      if (latestVersion == null || latestVersion.isEmpty) {
        _showMessage(l10n.update_latest_release_unavailable);
      } else {
        final compare = UpdateService.compareVersions(current, latestVersion);
        if (compare >= 0) {
          _showMessage(l10n.settings_latest_version(currentVersion));
        } else {
          final shouldDownload = await _confirmUpdateDownload(latestVersion);
          if (!shouldDownload) return;

          final assetName = _preferredUpdateAssetName(latestVersion);
          final artifact = _updateService.verifiedAsset(
            latestRelease?.data,
            assetName ?? '',
          );
          if (assetName == null || artifact == null) {
            _showMessage(l10n.update_asset_not_found);
            return;
          }

          final file = await _updateService.downloadVerifiedAsset(
            uri: artifact.uri,
            assetName: assetName,
            digest: artifact.digest,
          );
          await OpenFilex.open(file.path);
        }
      }
    } catch (e) {
      if (!mounted) return;

      final code = ErrorClassifier.codeFor(e);
      debugPrint('Update check failed: $code');
      _showMessage(localizedErrorMessage(l10n, code));
    } finally {
      if (mounted) {
        setState(() => _checking = false);
      }
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<bool> _confirmUpdateDownload(String latestVersion) async {
    final l10n = AppLocalizations.of(context);
    final assetName = _preferredUpdateAssetName(latestVersion);
    if (assetName == null) {
      _showMessage(l10n.update_direct_download_unsupported);
      return false;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.update_available),
          content: Text(l10n.update_download_prompt(latestVersion, assetName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.update_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.update_download),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings_title)),
      body: FutureBuilder<PackageInfo>(
        future: _pkgInfo,
        builder: (context, snap) {
          final pkg = snap.data;
          final version = pkg?.version ?? 'unknown';

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              ListTile(
                title: Text(l10n.settings_language),
                subtitle: Text(_describeLocale(appState.locale, l10n)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguageDialog(appState),
              ),
              ListTile(
                title: Text(l10n.settings_theme),
                subtitle: Text(_describeThemeMode(appState.themeMode, l10n)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeDialog(appState),
              ),
              ListTile(
                title: Text(l10n.settings_exchange_api_source),
                subtitle: Text(
                  _describeExchangeApiSource(appState.exchangeApiSource, l10n),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showExchangeApiSourceDialog(appState),
              ),
              ListTile(
                title: Text(l10n.settings_clear_local_data),
                subtitle: Text(l10n.settings_clear_local_data_subtitle),
                trailing: const Icon(Icons.delete_outline),
                onTap: () => _confirmClearLocalData(appState),
              ),
              ListTile(
                title: Text(l10n.settings_app_version),
                subtitle: Text(version),
                trailing: _checking
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton(
                        onPressed: () => _checkForUpdates(version),
                        child: Text(l10n.settings_check_updates),
                      ),
              ),
              const Divider(),
              ListTile(
                title: Text(l10n.settings_changelogs),
                subtitle: Text(l10n.settings_changelogs_subtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChangelogScreen()),
                ),
              ),
              const Divider(),
              ListTile(
                title: Text(l10n.settings_license),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LicensePage(
                      appName: pkg?.appName ?? 'OpenFXpedia',
                      version: version,
                    ),
                  ),
                ),
              ),
              ListTile(
                title: Text(l10n.settings_privacy),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPage()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _describeThemeMode(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.settings_light;
      case ThemeMode.dark:
        return l10n.settings_dark;
      case ThemeMode.system:
        return l10n.settings_system;
    }
  }

  String _describeLocale(Locale? locale, AppLocalizations l10n) {
    if (locale == null) return l10n.settings_system;
    if (locale.languageCode == 'zh' && locale.scriptCode == 'Hans') {
      return l10n.language_simplified_chinese;
    }
    if (locale.languageCode == 'zh' && locale.scriptCode == 'Hant') {
      return l10n.language_traditional_chinese;
    }
    return l10n.language_english;
  }

  String _describeExchangeApiSource(
    ExchangeApiSource source,
    AppLocalizations l10n,
  ) {
    switch (source) {
      case ExchangeApiSource.auto:
        return l10n.settings_exchange_api_source_auto;
      case ExchangeApiSource.frankfurter:
        return l10n.provider_frankfurter;
      case ExchangeApiSource.exchangeApi:
        return l10n.provider_exchange_api;
    }
  }

  Future<void> _showLanguageDialog(AppState state) async {
    final l10n = AppLocalizations.of(context);
    final chosen = await showDialog<Locale?>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text(l10n.settings_language_dialog_title),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Text(l10n.settings_language_dialog_subtitle),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, null),
              child: Text(l10n.settings_system),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(
                ctx,
                const Locale.fromSubtags(
                  languageCode: 'zh',
                  scriptCode: 'Hant',
                ),
              ),
              child: Text(l10n.language_traditional_chinese),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(
                ctx,
                const Locale.fromSubtags(
                  languageCode: 'zh',
                  scriptCode: 'Hans',
                ),
              ),
              child: Text(l10n.language_simplified_chinese),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, const Locale('en')),
              child: Text(l10n.language_english),
            ),
          ],
        );
      },
    );

    await state.setLocale(chosen);
  }

  Future<void> _showThemeDialog(AppState state) async {
    final l10n = AppLocalizations.of(context);
    final chosen = await showDialog<ThemeMode>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text(l10n.settings_select_theme),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, ThemeMode.system),
              child: Text(l10n.settings_system),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, ThemeMode.light),
              child: Text(l10n.settings_light),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, ThemeMode.dark),
              child: Text(l10n.settings_dark),
            ),
          ],
        );
      },
    );

    if (chosen != null) await state.setThemeMode(chosen);
  }

  Future<void> _showExchangeApiSourceDialog(AppState state) async {
    final l10n = AppLocalizations.of(context);
    final chosen = await showDialog<ExchangeApiSource>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text(l10n.settings_select_exchange_api_source),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, ExchangeApiSource.auto),
              child: Text(l10n.settings_exchange_api_source_auto),
            ),
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.pop(ctx, ExchangeApiSource.frankfurter),
              child: Text(l10n.provider_frankfurter),
            ),
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.pop(ctx, ExchangeApiSource.exchangeApi),
              child: Text(l10n.provider_exchange_api),
            ),
          ],
        );
      },
    );

    if (chosen != null) await state.setExchangeApiSource(chosen);
  }

  Future<void> _confirmClearLocalData(AppState state) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.settings_clear_local_data_title),
          content: Text(l10n.settings_clear_local_data_message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.converter_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.settings_clear_local_data_confirm),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    try {
      await state.clearLocalData();
      if (mounted) _showMessage(l10n.settings_clear_local_data_done);
    } catch (_) {
      if (mounted) _showMessage(l10n.settings_clear_local_data_failed);
    }
  }

  String? _preferredUpdateAssetName(String latestVersion) {
    final resolver = widget.updateAssetNameResolver;
    if (resolver != null) return resolver(latestVersion);

    if (Platform.isWindows) {
      return 'openfxpedia_${latestVersion}_setup.exe';
    }

    if (Platform.isAndroid) {
      return 'openfxpedia_$latestVersion.apk';
    }

    return null;
  }
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final paragraphs = [
      l10n.privacy_statement_no_account,
      l10n.privacy_statement_network,
      l10n.privacy_statement_local_storage,
      l10n.privacy_statement_data_deletion,
      l10n.privacy_statement_android,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings_privacy)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final paragraph in paragraphs) ...[
            Text(paragraph),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class LicensePage extends StatefulWidget {
  final String appName;
  final String version;

  const LicensePage({super.key, required this.appName, required this.version});

  @override
  State<LicensePage> createState() => _LicensePageState();
}

class _LicensePageState extends State<LicensePage> {
  late Future<String> _license;

  @override
  void initState() {
    super.initState();
    _license = rootBundle.loadString('LICENSE');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings_license),
      ),
      body: FutureBuilder<String>(
        future: _license,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Failed to load LICENSE: ${snapshot.error}'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '${widget.appName} ${widget.version}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              const SizedBox(height: 16),
              SelectableText(snapshot.data ?? ''),
            ],
          );
        },
      ),
    );
  }
}
