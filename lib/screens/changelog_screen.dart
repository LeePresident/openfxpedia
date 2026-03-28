import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../l10n/app_localizations.dart';

class ChangelogScreen extends StatefulWidget {
  const ChangelogScreen({super.key});

  @override
  State<ChangelogScreen> createState() => _ChangelogScreenState();
}

class _ChangelogScreenState extends State<ChangelogScreen> {
  late Future<List<_ChangelogEntry>> _entries;

  @override
  void initState() {
    super.initState();
    _entries = _loadEntries();
  }

  Future<List<_ChangelogEntry>> _loadEntries() async {
    final raw =
        await rootBundle.loadString('assets/data/changelog_entries.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(_ChangelogEntry.fromJson)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeKey = _localeKeyFor(l10n.localeName);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings_changelogs)),
      body: FutureBuilder<List<_ChangelogEntry>>(
        future: _entries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Failed to load changelogs: ${snapshot.error}'),
              ),
            );
          }

          final entries = snapshot.data ?? const [];
          if (entries.isEmpty) {
            return const Center(child: Text('No changelogs available yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = entries[index].localize(localeKey);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.version} • ${entry.dateLabel}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (entry.summary.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(entry.summary),
                      ],
                      if (entry.highlights.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ...entry.highlights.map(
                          (highlight) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('• $highlight'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ChangelogEntry {
  final String version;
  final String dateLabel;
  final String summary;
  final List<String> highlights;
  final Map<String, _LocalizedChangelog> translations;

  const _ChangelogEntry({
    required this.version,
    required this.dateLabel,
    required this.summary,
    required this.highlights,
    required this.translations,
  });

  factory _ChangelogEntry.fromJson(Map<String, dynamic> json) {
    final translations = <String, _LocalizedChangelog>{};
    final rawTranslations = json['translations'];
    if (rawTranslations is Map<String, dynamic>) {
      for (final entry in rawTranslations.entries) {
        final value = entry.value;
        if (value is Map<String, dynamic>) {
          translations[entry.key] = _LocalizedChangelog.fromJson(value);
        }
      }
    }

    return _ChangelogEntry(
      version: (json['version'] as String?)?.trim() ?? '',
      dateLabel: (json['date'] as String?)?.trim() ?? '',
      summary: (json['summary'] as String?)?.trim() ?? '',
      highlights: (json['highlights'] as List<dynamic>?)
              ?.whereType<String>()
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList() ??
          const [],
      translations: translations,
    );
  }

  _LocalizedChangelog localize(String localeKey) {
    return translations[localeKey] ??
        translations[_languageFallback(localeKey)] ??
        translations['en'] ??
        _LocalizedChangelog(
          version: version,
          dateLabel: dateLabel,
          summary: summary,
          highlights: highlights,
        );
  }
}

class _LocalizedChangelog {
  final String version;
  final String dateLabel;
  final String summary;
  final List<String> highlights;

  const _LocalizedChangelog({
    required this.version,
    required this.dateLabel,
    required this.summary,
    required this.highlights,
  });

  factory _LocalizedChangelog.fromJson(Map<String, dynamic> json) {
    return _LocalizedChangelog(
      version: (json['version'] as String?)?.trim() ?? '',
      dateLabel: (json['date'] as String?)?.trim() ?? '',
      summary: (json['summary'] as String?)?.trim() ?? '',
      highlights: (json['highlights'] as List<dynamic>?)
              ?.whereType<String>()
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList() ??
          const [],
    );
  }
}

String _localeKeyFor(String localeName) {
  final normalized = localeName.replaceAll('-', '_');
  if (normalized.startsWith('zh_Hant')) return 'zh_Hant';
  if (normalized.startsWith('zh_Hans')) return 'zh_Hans';
  if (normalized.startsWith('zh')) return 'zh_Hant';
  if (normalized.startsWith('en')) return 'en';
  return 'en';
}

String _languageFallback(String localeKey) {
  if (localeKey.startsWith('zh')) return 'zh_Hant';
  return 'en';
}
