---
name: flutter-validation
description: 'Validate OpenFXpedia Flutter changes. Use when formatting Dart, running static analysis, selecting unit/widget/integration tests, reproducing CI, checking coverage, or diagnosing a failed validation command.'
argument-hint: '[changed area or failing test]'
---

# Flutter Validation

Use the smallest check that can falsify the current change, then expand only as needed.

## Procedure

1. Identify the changed production files and their nearest tests under `test/unit/`, `test/widget/`, or `test/integration/`.
2. If dependencies or generated localization changed, run `flutter pub get` first.
3. Format changed Dart files with `dart format <paths>`. Never use `flutter format`.
4. Run the nearest test file:

   ```powershell
   flutter test test/path/to/relevant_test.dart
   ```

5. Run `flutter analyze` after the focused test passes.
6. Run the complete suite for shared services, application state, localization, navigation, persistence, or release-bound changes:

   ```powershell
   flutter test
   ```

7. To reproduce CI exactly, run:

   ```powershell
   flutter pub get
   dart format --set-exit-if-changed .
   flutter analyze
   flutter test --coverage
   ```

## Test Selection

- Model, parsing, conversion, caching, or API behavior: start in `test/unit/`.
- Widget rendering, interaction, accessibility, or locale behavior: start in `test/widget/`.
- Cross-screen or end-to-end flows: use `test/integration/`.
- Changes to `lib/providers/app_state.dart` often require both unit and widget coverage.

Do not update tests merely to accept a regression. Confirm whether the implementation or the expectation violates the current product behavior.
