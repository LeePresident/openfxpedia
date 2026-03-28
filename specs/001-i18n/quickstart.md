# Quickstart: Multi-Language App Support

## Prerequisites

- Flutter SDK installed and available on `PATH`.
- Repository dependencies installed with `flutter pub get`.

## Verify the Feature Locally

1. Run the app on Windows or Android.
2. Open Settings.
3. Change the language between English, Traditional Chinese, and Simplified Chinese.
4. Confirm that screen titles, navigation labels, prompts, and other visible text update immediately.
5. Restart the app and confirm the selected language persists.
6. Verify the localization sources are split across `lib/l10n/app_zh.arb`, `lib/l10n/app_zh_Hans.arb`, and `lib/l10n/app_zh_Hant.arb`, with the neutral `zh` file acting as the Traditional Chinese fallback and generated outputs in `lib/l10n/app_localizations_zh.dart`, `lib/l10n/app_localizations_zh_Hans.dart`, and `lib/l10n/app_localizations_zh_Hant.dart`.

## Adding a New Translation Later

1. Add a new ARB file under `lib/l10n/` for the target locale.
2. Add the locale to the supported locales list.
3. Fill in translated values for all user-facing strings.
4. Regenerate localization output using Flutter's localization tooling.
5. Add or update widget tests that exercise the new locale.
6. If you are updating Chinese translations, edit `app_zh.arb` when you need the neutral Traditional Chinese fallback, `app_zh_Hans.arb` for Simplified Chinese, or `app_zh_Hant.arb` for the explicit Traditional Chinese variant.

## Validation Checklist

- The app starts in the device language when that language is supported.
- The app falls back to English when the device language is unsupported.
- Both Chinese variants can be selected independently.
- Switching language does not reset the current screen state.
- Missing strings fall back cleanly without blank labels.
