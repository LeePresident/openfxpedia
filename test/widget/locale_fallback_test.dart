import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:openfxpedia/l10n/app_localizations.dart';
import 'package:openfxpedia/l10n/app_localizations_en.dart';
import 'package:openfxpedia/screens/changelog_screen.dart';
import 'package:openfxpedia/services/observability.dart';

void main() {
  testWidgets('partial UI locale falls back to English for missing strings', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
        supportedLocales: [
          Locale('en'),
          Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
        ],
        localizationsDelegates: [
          _PartialUiDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: _UiFallbackProbe(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('语言'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('changelog content falls back to English and logs the fallback', (
    tester,
  ) async {
    LocalizationObservability.clear();

    const jsonFixture = '''
[
  {
    "version": "1.2.3",
    "date": "2026-04-03",
    "summary": "English summary",
    "highlights": ["English highlight"],
    "translations": {
      "en": {
        "version": "1.2.3",
        "date": "2026-04-03",
        "summary": "English summary",
        "highlights": ["English highlight"]
      },
      "zh_Hant": {
        "version": "1.2.3",
        "date": "2026-04-03",
        "summary": "繁體摘要",
        "highlights": ["繁體重點"]
      }
    }
  }
]
''';

    await tester.pumpWidget(
      MaterialApp(
        locale:
            const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: ChangelogScreen(
            bundle: _MapAssetBundle({
          'assets/data/changelog_entries.json': jsonFixture,
        })),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('English summary'), findsOneWidget);
    expect(find.text('• English highlight'), findsOneWidget);
    expect(
      LocalizationObservability.events,
      anyElement(
        predicate<Map<String, String>>((event) =>
            event['event'] == 'localization_fallback' &&
            event['surface'] == 'changelog' &&
            event['locale'] == 'zh_Hans' &&
            event['fallback'] == 'en'),
      ),
    );
  });
}

class _UiFallbackProbe extends StatelessWidget {
  const _UiFallbackProbe();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          Text(l10n.settings_language),
          Text(l10n.settings_title),
        ],
      ),
    );
  }
}

class _PartialUiLocalizations extends AppLocalizationsEn {
  _PartialUiLocalizations() : super('zh_Hans');

  @override
  // ignore: non_constant_identifier_names
  String get settings_language => '语言';
}

class _PartialUiDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _PartialUiDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'zh';

  @override
  Future<AppLocalizations> load(Locale locale) async {
    if (locale.languageCode == 'zh') {
      return _PartialUiLocalizations();
    }
    return AppLocalizationsEn();
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

class _MapAssetBundle extends CachingAssetBundle {
  final Map<String, String> assets;

  _MapAssetBundle(this.assets);

  @override
  Future<ByteData> load(String key) async {
    final content = assets[key];
    if (content == null) {
      throw FlutterError('Missing test asset: $key');
    }
    final bytes = utf8.encode(content);
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }
}
