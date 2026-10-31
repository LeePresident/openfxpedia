# Localization support

[English](README.md) | [简体中文](README.zh-Hans.md) | [繁體中文](README.zh-Hant.md)

This project enables Flutter localization delegates in `lib/main.dart` and currently declares support for:
- `en` (English)
- `zh` (Traditional Chinese fallback)
- `zh_Hans` (Simplified Chinese)
- `zh_Hant` (Traditional Chinese, Hong Kong usage)

Localization messages are provided by `lib/l10n/app_localizations.dart` as the shared entry point, with ARB source files in this directory.
The checked-in generated implementations are `app_localizations_en.dart` and `app_localizations_zh.dart`; the latter contains the neutral `zh`, Simplified Chinese, and Traditional Chinese implementations.

To expand translations later:
1. Add new keys to `app_en.arb` first, then keep the ARB files for the other supported locales aligned. Add a new ARB file when introducing a new locale.
2. Run `flutter gen-l10n`, then `dart format lib/l10n` from the repository root to regenerate and format the checked-in localization output. Do not edit the generated Dart files manually.
3. Replace hard-coded strings incrementally with localized message lookups.

## Right-to-left readiness

Arabic and Hebrew are not currently supported locales. When adding an RTL locale, add its ARB/generated localization and include it in the supported locales as usual. `GlobalWidgetsLocalizations.delegate` already derives `Directionality` from the resolved locale; keep it enabled and do not force the app to left-to-right.

Use directional layout APIs such as `EdgeInsetsDirectional`, `AlignmentDirectional`, `TextAlign.start`/`end`, `BorderDirectional`, and `PositionedDirectional` for leading/trailing UI. Add widget tests for RTL direction and layout when introducing the locale. `test/widget/rtl_directionality_test.dart` verifies Flutter's locale-driven direction behavior without adding an RTL translation today.

Notes:
- `app_zh.arb` is the neutral Chinese fallback source file used when the device reports `zh` without a script code.
- `app_localizations_zh.dart` contains the neutral Chinese fallback implementation and the script-specific Chinese implementations.
- `app_zh_Hans.arb` is the Simplified Chinese source file.
- `app_zh_Hant.arb` is the Traditional Chinese source file.
