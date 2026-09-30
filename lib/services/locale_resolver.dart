import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

class LocaleResolver {
  static String catalogKey(Locale? locale) {
    if (locale?.languageCode == 'zh') {
      return 'zh_${_preferredChineseScript(locale!)}';
    }
    return 'en';
  }

  static Locale? resolveSystemLocale(Iterable<Locale> locales) {
    for (final locale in locales) {
      if (locale.languageCode == 'zh') {
        final preferredScript = _preferredChineseScript(locale);
        for (final supported in AppLocalizations.supportedLocales) {
          if (supported.languageCode == 'zh' &&
              supported.scriptCode == preferredScript) {
            return supported;
          }
        }
      }

      final exactMatch =
          _matchSupportedLocale(locale, allowLanguageOnly: false);
      if (exactMatch != null) return exactMatch;

      final languageMatch =
          _matchSupportedLocale(locale, allowLanguageOnly: true);
      if (languageMatch != null) return languageMatch;
    }
    return null;
  }

  static String _preferredChineseScript(Locale locale) {
    final scriptCode = locale.scriptCode;
    if (scriptCode == 'Hans' || scriptCode == 'Hant') {
      return scriptCode!;
    }

    switch (locale.countryCode?.toUpperCase()) {
      case 'CN':
      case 'SG':
      case 'MY':
        return 'Hans';
      default:
        return 'Hant';
    }
  }

  static Locale? _matchSupportedLocale(
    Locale locale, {
    required bool allowLanguageOnly,
  }) {
    for (final supported in AppLocalizations.supportedLocales) {
      if (locale.languageCode != supported.languageCode) continue;

      final scriptsMatch = locale.scriptCode == supported.scriptCode;
      final countriesMatch = supported.countryCode == null ||
          locale.countryCode == null ||
          locale.countryCode == supported.countryCode;

      if (scriptsMatch && countriesMatch) return supported;
      if (allowLanguageOnly &&
          supported.scriptCode == null &&
          supported.countryCode == null) {
        return supported;
      }
    }
    return null;
  }
}
