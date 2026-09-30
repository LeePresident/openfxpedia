import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/services/locale_resolver.dart';

void main() {
  for (final example in <(Locale, String)>[
    (const Locale('zh', 'HK'), 'Hant'),
    (const Locale('zh', 'MO'), 'Hant'),
    (const Locale('zh', 'TW'), 'Hant'),
    (const Locale('zh', 'CN'), 'Hans'),
    (const Locale('zh', 'SG'), 'Hans'),
    (const Locale('zh', 'MY'), 'Hans'),
    (const Locale('zh'), 'Hant'),
    (const Locale('zh', 'US'), 'Hant'),
    (
      const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
        countryCode: 'HK',
      ),
      'Hans',
    ),
    (
      const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hant',
        countryCode: 'CN',
      ),
      'Hant',
    ),
    (
      const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Latn',
        countryCode: 'CN',
      ),
      'Hans',
    ),
    (
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Latn'),
      'Hant',
    ),
  ]) {
    test('UI and catalog agree on Chinese locale ${example.$1}', () {
      expect(
        LocaleResolver.resolveSystemLocale([example.$1]),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: example.$2),
      );
      expect(LocaleResolver.catalogKey(example.$1), 'zh_${example.$2}');
    });
  }

  for (final locale in <Locale?>[
    null,
    const Locale('en'),
    const Locale('fr')
  ]) {
    test('catalog falls back to English for $locale', () {
      expect(LocaleResolver.catalogKey(locale), 'en');
    });
  }

  test('system locale selection respects language preference order', () {
    expect(
      LocaleResolver.resolveSystemLocale(const [
        Locale('fr'),
        Locale('en', 'GB'),
        Locale('zh', 'CN'),
      ]),
      const Locale('en'),
    );
    expect(
      LocaleResolver.resolveSystemLocale(const [
        Locale('fr'),
        Locale('zh', 'CN'),
        Locale('en', 'GB'),
      ]),
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    );
  });

  test('system locale falls back to a supported language without a script', () {
    expect(
      LocaleResolver.resolveSystemLocale(const [
        Locale.fromSubtags(
          languageCode: 'en',
          scriptCode: 'Latn',
          countryCode: 'US',
        ),
      ]),
      const Locale('en'),
    );
  });

  test('unsupported or empty system locales leave the default unresolved', () {
    expect(LocaleResolver.resolveSystemLocale(const [Locale('fr')]), isNull);
    expect(LocaleResolver.resolveSystemLocale(const []), isNull);
  });
}
