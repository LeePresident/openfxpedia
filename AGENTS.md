# OpenFXpedia Agent Guidelines

These instructions apply to the entire repository. Keep changes focused, preserve existing behavior outside the requested scope, and do not edit generated build output under `build/`.

## Project Shape

OpenFXpedia is a Flutter application for Windows and Android. It combines a currency converter with an offline-friendly currency encyclopedia.

- `lib/models/`: domain data objects.
- `lib/services/`: exchange-rate, persistence, catalog, update, and platform integrations.
- `lib/providers/app_state.dart`: application state and orchestration.
- `lib/screens/` and `lib/widgets/`: user-facing Flutter UI.
- `lib/l10n/`: ARB sources and checked-in localization output.
- `assets/data/`: canonical bundled currency data, locale overlays, and changelog data.
- `test/unit/`, `test/widget/`, and `test/integration/`: tests grouped by scope.
- `specs/`: feature specifications and historical implementation plans. Verify current code before relying on an older plan.

## Implementation Rules

- Follow existing Dart and Flutter patterns and the lints in `analysis_options.yaml`.
- Keep business logic in services or providers rather than embedding it in widgets.
- Preserve user state across theme, locale, navigation, and refresh changes.
- Keep network access behind the existing exchange client/provider abstractions. Preserve cached and offline fallback behavior.
- Use `CacheService` for persisted preferences and cached data. On Windows, Hive must use the application support directory rather than a potentially OneDrive-backed documents directory.
- Treat `assets/data/fiat_currencies.json` as the canonical bundled fiat dataset. Locale files are field-level overlays, not independent copies.
- Keep `pubspec.yaml` asset declarations synchronized with added or moved assets.
- Do not manually edit files under `build/`, `coverage/`, or generated platform intermediates.

## Localization

- Put user-facing text in the ARB files under `lib/l10n/`; do not add avoidable hard-coded UI strings.
- Add English keys first, then keep `app_zh.arb`, `app_zh_Hans.arb`, and `app_zh_Hant.arb` aligned.
- Run `flutter gen-l10n` after ARB changes. Localization output is checked in.
- Preserve English field-level fallback for encyclopedia overlays in `assets/data/fiat_currency_overlays/`.
- Follow the `localization-update` skill for the complete workflow.

## Validation

Run the narrowest relevant test first, then broaden validation according to the change risk.

```powershell
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Use `flutter test --coverage` when reproducing CI. Do not use `flutter format`; formatting is provided by `dart format`.

For targeted checks, pass the relevant test path, for example:

```powershell
flutter test test/unit/exchange_client_primary_fallback_test.dart
flutter test test/widget/encyclopedia_locale_test.dart
```

## Releases

- The package version in `pubspec.yaml`, `CHANGELOG.md`, `releases/`, and bundled changelog data must agree.
- Use the scripts under `scripts/` for distributable builds; do not rename artifacts independently of those scripts.
- Windows release installers require NSIS. Android release builds produce an APK and SHA-1 file.

## Available Skills

Load the relevant workflow from `.agents/skills/` when a task matches it:

- `flutter-validation`: formatting, analysis, test selection, and CI-equivalent checks.
- `localization-update`: UI strings, ARB generation, locale fallback, and encyclopedia overlays.
- `exchange-rate-pipeline`: providers, source selection, fallback, caching, and rate attribution.
- `currency-catalog-maintenance`: fiat metadata, ISO codes, regions, flags, icons, and asset validation.
- `release-preparation`: versioning, release notes, changelog data, and Windows/Android artifacts.

