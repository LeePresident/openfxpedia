# Localization support

This project enables Flutter localization delegates in `lib/main.dart` and currently declares support for:
- `en` (English)
- `zh` (Chinese)

To expand translations later:
1. Add generated-l10n configuration in `pubspec.yaml`.
2. Add `arb` files (for example `app_en.arb`, `app_zh.arb`).
3. Replace hard-coded strings incrementally with localized message lookups.
