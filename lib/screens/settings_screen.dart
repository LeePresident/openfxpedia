import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/config.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import 'changelog_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<PackageInfo> _pkgInfo;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _pkgInfo = PackageInfo.fromPlatform();
  }

  Future<void> _checkForUpdates(String currentVersion) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _checking = true);
    try {
      final latestRelease = await _fetchLatestStableRelease();
      final latestVersion = _normalizeVersion(
        latestRelease?['tag_name'] as String?,
      );
      final current = _normalizeVersion(currentVersion);

      if (latestVersion == null || latestVersion.isEmpty) {
        _showMessage('Unable to determine latest stable release from GitHub.');
      } else {
        final compare = _compareSemver(current, latestVersion);
        if (compare >= 0) {
          _showMessage(l10n.settings_latest_version(currentVersion));
        } else {
          final shouldDownload = await _confirmUpdateDownload(latestVersion);
          if (!shouldDownload) return;

          final assetUrl = _releaseAssetUrlForDevice(
            latestRelease,
            latestVersion,
          );
          if (assetUrl == null || assetUrl.isEmpty) {
            _showMessage(
              'No release asset found for this device on GitHub releases.',
            );
            return;
          }

          final opened = await launchUrl(
            Uri.parse(assetUrl),
            mode: LaunchMode.externalApplication,
          );
          if (!opened) {
            _showMessage('Could not open the GitHub release download link.');
          }
        }
      }
    } catch (e) {
      _showMessage('Update check failed: $e');
    } finally {
      setState(() => _checking = false);
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<bool> _confirmUpdateDownload(String latestVersion) async {
    final assetName = _preferredUpdateAssetName(latestVersion);
    if (assetName == null) {
      _showMessage(
        'This device is not supported for direct release downloads.',
      );
      return false;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update available'),
          content: Text(
            'Version $latestVersion is available.\n\nDownload $assetName from GitHub releases for this device?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Download'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  String? _normalizeVersion(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    var value = raw.trim();
    if (value.startsWith('v') || value.startsWith('V')) {
      value = value.substring(1);
    }
    final plus = value.indexOf('+');
    if (plus >= 0) {
      value = value.substring(0, plus);
    }
    final hyphen = value.indexOf('-');
    if (hyphen >= 0) {
      value = value.substring(0, hyphen);
    }
    return value;
  }

  Future<List<Map<String, dynamic>>> _fetchAllGithubReleases() async {
    final releases = <Map<String, dynamic>>[];
    var page = 1;

    while (true) {
      final pageUri = Uri.parse('${AppConfig.githubReleasesApiUrl}&page=$page');
      final res = await http.get(pageUri, headers: {
        'Accept': 'application/vnd.github+json',
      }).timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) {
        throw Exception('GitHub releases request failed (${res.statusCode})');
      }

      final pageItems = jsonDecode(res.body) as List<dynamic>;
      if (pageItems.isEmpty) {
        break;
      }

      releases.addAll(pageItems.cast<Map<String, dynamic>>());
      page++;
    }

    return releases;
  }

  Future<Map<String, dynamic>?> _fetchLatestStableRelease() async {
    final releases = await _fetchAllGithubReleases();
    for (final release in releases) {
      final isDraft = release['draft'] == true;
      final isPreRelease = release['prerelease'] == true;
      if (isDraft || isPreRelease) continue;

      final tagName = release['tag_name'] as String?;
      final normalized = _normalizeVersion(tagName);
      if (normalized != null && normalized.isNotEmpty) {
        return release;
      }
    }

    return null;
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
                  MaterialPageRoute(
                    builder: (_) => const ChangelogScreen(),
                  ),
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
    if (locale.languageCode == 'zh') {
      return l10n.language_traditional_chinese;
    }
    return l10n.language_english;
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
                    languageCode: 'zh', scriptCode: 'Hant'),
              ),
              child: Text(l10n.language_traditional_chinese),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(
                ctx,
                const Locale.fromSubtags(
                    languageCode: 'zh', scriptCode: 'Hans'),
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

  String? _preferredUpdateAssetName(String latestVersion) {
    if (Platform.isWindows) {
      return 'openfxpedia_${latestVersion}_setup.exe';
    }

    if (Platform.isAndroid) {
      return 'openfxpedia_$latestVersion.apk';
    }

    return null;
  }

  String? _releaseAssetUrlForDevice(
    Map<String, dynamic>? release,
    String latestVersion,
  ) {
    final assetName = _preferredUpdateAssetName(latestVersion);
    if (assetName == null || release == null) return null;

    final assets = release['assets'];
    if (assets is List) {
      for (final asset in assets) {
        if (asset is Map<String, dynamic> && asset['name'] == assetName) {
          final url = asset['browser_download_url'] as String?;
          if (url != null && url.isNotEmpty) return url;
        }
      }
    }

    return null;
  }

  int _compareSemver(String? current, String? latest) {
    final currentParts = (current ?? '0.0.0').split('.');
    final latestParts = (latest ?? '0.0.0').split('.');
    final maxLen = currentParts.length > latestParts.length
        ? currentParts.length
        : latestParts.length;

    for (var i = 0; i < maxLen; i++) {
      final a =
          i < currentParts.length ? int.tryParse(currentParts[i]) ?? 0 : 0;
      final b = i < latestParts.length ? int.tryParse(latestParts[i]) ?? 0 : 0;
      if (a != b) return a.compareTo(b);
    }
    return 0;
  }
}

class LicensePage extends StatefulWidget {
  final String appName;
  final String version;

  const LicensePage({
    super.key,
    required this.appName,
    required this.version,
  });

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
      appBar:
          AppBar(title: Text(AppLocalizations.of(context).settings_license)),
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
