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
  late Future<List<_ReleaseNote>> _releaseNotes;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _pkgInfo = PackageInfo.fromPlatform();
    _releaseNotes = _fetchReleaseNotes();
  }

  Future<List<_ReleaseNote>> _fetchReleaseNotes() async {
    final allReleases = await _fetchAllGithubReleases();
    return allReleases
        .map((item) => _ReleaseNote.fromJson(item))
        .where((entry) => entry.name.isNotEmpty || entry.body.isNotEmpty)
        .toList();
  }

  Future<void> _checkForUpdates(String currentVersion) async {
    setState(() => _checking = true);
    try {
      final latestVersion = await _fetchLatestStableReleaseVersion();
      final current = _normalizeVersion(currentVersion);

      if (latestVersion == null || latestVersion.isEmpty) {
        _showMessage('Unable to determine latest stable release from GitHub.');
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
                title: const Text('Changelogs'),
                subtitle: const Text('Fetched from GitHub release notes'),
                children: [
                  FutureBuilder<List<_ReleaseNote>>(
                    future: _releaseNotes,
                    builder: (context, releaseSnap) {
                      if (releaseSnap.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (releaseSnap.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Failed to load release notes: ${releaseSnap.error}',
                          ),
                        );
                      }

                      final entries = releaseSnap.data ?? const [];
                      if (entries.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No release notes available yet.'),
                        );
                      }

                      return Column(
                        children: entries
                            .map(
                              (entry) => ListTile(
                                dense: true,
                                title: Text(entry.name),
                                subtitle: SelectableText(entry.body),
                                trailing: Text(entry.dateLabel),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
              const Divider(),
              ListTile(
                title: const Text('License'),
                subtitle: const Text(
                    'OpenFXpedia — Currency Converter and Encyclopedia.'),
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

  Future<String?> _fetchLatestStableReleaseVersion() async {
    final releases = await _fetchAllGithubReleases();
    for (final release in releases) {
      final isDraft = release['draft'] == true;
      final isPreRelease = release['prerelease'] == true;
      if (isDraft || isPreRelease) continue;

      final tagName = release['tag_name'] as String?;
      final normalized = _normalizeVersion(tagName);
      if (normalized != null && normalized.isNotEmpty) {
        return normalized;
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

class _ReleaseNote {
  final String name;
  final String body;
  final String dateLabel;

  const _ReleaseNote({
    required this.name,
    required this.body,
    required this.dateLabel,
  });

  factory _ReleaseNote.fromJson(Map<String, dynamic> json) {
    final rawName = (json['name'] as String?)?.trim();
    final tag = (json['tag_name'] as String?)?.trim() ?? '';
    final body = (json['body'] as String?)?.trim() ?? '';
    final publishedAt = (json['published_at'] as String?)?.trim() ?? '';

    final dateLabel =
        publishedAt.length >= 10 ? publishedAt.substring(0, 10) : publishedAt;

    return _ReleaseNote(
      name: (rawName == null || rawName.isEmpty) ? tag : rawName,
      body: body,
      dateLabel: dateLabel,
    );
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
      appBar: AppBar(title: const Text('License')),
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
