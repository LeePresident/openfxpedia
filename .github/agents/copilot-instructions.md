# openfxpedia Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-03-26

## Active Technologies

- Dart 3 / Flutter (current repo SDK range `>=3.0.0 <4.0.0`)
- `flutter_localizations`
- `intl`
- `provider`
- `hive_flutter`
- Hive-backed preference storage via the existing `CacheService` prefs box

## Project Structure

```text
lib/
├── l10n/
├── providers/
├── screens/
├── services/
└── widgets/

test/
├── integration/
├── unit/
└── widget/
```

## Commands

flutter pub get
flutter analyze
flutter test

## Code Style

Use Flutter and Dart conventions. Keep localization strings in ARB files, use generated localization delegates, and preserve the existing app state when switching locale.

## Recent Changes

- 001-i18n: Added app-wide localization with persisted language preference, device-locale fallback, and support for English and Chinese.

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
