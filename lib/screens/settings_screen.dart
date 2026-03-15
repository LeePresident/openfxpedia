import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../core/config.dart';
import '../providers/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<PackageInfo> _pkgInfo;
  late Future<String> _changelog;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _pkgInfo = PackageInfo.fromPlatform();
    _changelog = rootBundle.loadString('CHANGELOG.md');
  }

  Future<void> _checkForUpdates(String currentVersion) async {
    setState(() => _checking = true);
    try {
      final res =
          await http.get(Uri.parse(AppConfig.githubTagsApiUrl), headers: {
        'Accept': 'application/vnd.github+json',
      }).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final tags = jsonDecode(res.body) as List<dynamic>;
        final latestTag = tags.isNotEmpty
            ? (tags.first as Map<String, dynamic>)['name'] as String?
            : null;
        final latestVersion = _normalizeVersion(latestTag);
        final current = _normalizeVersion(currentVersion);

        if (latestVersion == null || latestVersion.isEmpty) {
          _showMessage('Unable to determine latest tag from GitHub.');
        } else {
          final compare = _compareSemver(current, latestVersion);
          if (compare >= 0) {
            _showMessage('You are on the latest version ($currentVersion).');
          } else {
            _showMessage(
              'Update available: $latestVersion (current $currentVersion)',
            );
          }
        }
      } else {
        _showMessage(
          'Failed to check GitHub tags (status ${res.statusCode}).',
        );
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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: FutureBuilder<PackageInfo>(
        future: _pkgInfo,
        builder: (context, snap) {
          final pkg = snap.data;
          final version = pkg?.version ?? 'unknown';

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              ListTile(
                title: const Text('Theme'),
                subtitle: Text(_describeThemeMode(appState.themeMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeDialog(appState),
              ),
              ListTile(
                title: const Text('App version'),
                subtitle: Text(version),
                trailing: _checking
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton(
                        onPressed: () => _checkForUpdates(version),
                        child: const Text('Check updates'),
                      ),
              ),
              const Divider(),
              ExpansionTile(
                title: const Text('Changelog'),
                subtitle: const Text('Show release notes'),
                children: [
                  FutureBuilder<String>(
                    future: _changelog,
                    builder: (context, changelogSnap) {
                      if (changelogSnap.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (changelogSnap.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                              'Failed to load changelog: ${changelogSnap.error}'),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: SelectableText(changelogSnap.data ?? ''),
                      );
                    },
                  ),
                ],
              ),
              const Divider(),
              ListTile(
                title: const Text('About'),
                subtitle: const Text(
                    'OpenFXpedia — Currency Converter and Encyclopedia.'),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: pkg?.appName ?? 'OpenFXpedia',
                  applicationVersion: version,
                  applicationLegalese: '© 2026 LeePresident',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _describeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  Future<void> _showThemeDialog(AppState state) async {
    final chosen = await showDialog<ThemeMode>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: const Text('Select theme'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, ThemeMode.system),
              child: const Text('System'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, ThemeMode.light),
              child: const Text('Light'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, ThemeMode.dark),
              child: const Text('Dark'),
            ),
          ],
        );
      },
    );

    if (chosen != null) await state.setThemeMode(chosen);
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
    return value;
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
