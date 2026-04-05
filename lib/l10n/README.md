# Localization support

This project enables Flutter localization delegates in `lib/main.dart` and currently declares support for:
- `en` (English)
- `zh` (Traditional Chinese fallback)
- `zh_Hans` (Simplified Chinese)
- `zh_Hant` (Traditional Chinese)

Localization messages are provided by `lib/l10n/app_localizations.dart` as the shared entry point, with ARB source files in this directory.
The checked-in generated implementations are split into `app_localizations_en.dart`, `app_localizations_zh.dart`, `app_localizations_zh_Hans.dart`, and `app_localizations_zh_Hant.dart`.

To expand translations later:
1. Add or update `arb` files for each locale you want to support.
2. Extend `AppLocalizations` (or switch to generated l10n output) with the new keys.
3. Replace hard-coded strings incrementally with localized message lookups.

Notes:
- `app_zh.arb` is the neutral Chinese fallback source file and should contain Traditional Chinese content.
- `app_localizations_zh.dart` is the neutral Chinese fallback implementation used when the device reports `zh` without a script code.
- `app_zh_Hans.arb` is the Simplified Chinese source file.
- `app_zh_Hant.arb` is the Traditional Chinese source file.
