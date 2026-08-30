---
name: localization-update
description: 'Update OpenFXpedia localization and translated currency content. Use when adding UI copy, editing ARB files, running gen-l10n, changing English/Simplified Chinese/Traditional Chinese translations, modifying locale fallback, or editing fiat currency overlays.'
argument-hint: '[string, screen, or currency content to localize]'
---

# Localization Update

OpenFXpedia supports English, neutral Chinese fallback, Simplified Chinese, and Traditional Chinese. UI messages and encyclopedia content use separate pipelines.

## UI Message Procedure

1. Add or change the key in `lib/l10n/app_en.arb` first. Preserve existing key naming and metadata conventions.
2. Apply the same key set to:
   - `lib/l10n/app_zh.arb`
   - `lib/l10n/app_zh_Hans.arb`
   - `lib/l10n/app_zh_Hant.arb`
3. Run:

   ```powershell
   flutter gen-l10n
   dart format lib/l10n
   ```

4. Replace hard-coded user-facing strings with `AppLocalizations` lookups.
5. Verify that every checked-in concrete localization class implements the generated API, especially the `zh_Hans` and `zh_Hant` classes.
6. Run the nearest locale widget test, then `flutter analyze`.

## Encyclopedia Content Procedure

1. Keep `assets/data/fiat_currencies.json` as the English/base source of truth.
2. Edit only translated fields in the matching overlay:
   - `assets/data/fiat_currency_overlays/en.json`
   - `assets/data/fiat_currency_overlays/zh_Hans.json`
   - `assets/data/fiat_currency_overlays/zh_Hant.json`
3. Key overlay entries by uppercase ISO code. Do not duplicate complete base records.
4. Preserve field-level English fallback and structured fallback reporting in `CurrencyCatalogService`.
5. Keep the overlay directory declared in `pubspec.yaml`.
6. Run:

   ```powershell
   flutter test test/widget/encyclopedia_locale_test.dart
   flutter test test/widget/locale_fallback_test.dart
   flutter analyze
   ```

## Behavioral Requirements

- Switching locale must not reset converter input, selected currencies, favorites, or browsing state.
- Missing translations must display readable English fallback text, never blank labels or raw keys.
- Locale mapping must distinguish `zh_Hans` and `zh_Hant`; neutral `zh` remains a fallback locale.

See `lib/l10n/README.md` and `specs/001-i18n/content-localization.md` for the established data contracts.
