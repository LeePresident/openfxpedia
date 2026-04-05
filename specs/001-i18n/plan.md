# Implementation Plan: Multi-Language App Support

**Branch**: `001-i18n` | **Date**: 2026-03-26 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-i18n/spec.md`

## Summary

Add app-wide localization so users can switch OpenFXpedia between English, Traditional Chinese, and Simplified Chinese from settings, have the choice persist across restarts, and keep the interface usable when some strings still fall back to the default language.

## Technical Context

**Language/Version**: Dart 3 / Flutter (current repo SDK range `>=3.0.0 <4.0.0`)  
**Primary Dependencies**: `flutter_localizations`, `intl`, `provider`, `hive_flutter`  
**Storage**: Hive-backed preference storage via the existing `CacheService` prefs box  
**Testing**: `flutter_test`, widget tests for locale switching, and persistence checks for startup locale selection  
**Target Platform**: Windows desktop and Android mobile  
**Project Type**: mobile-app + desktop-app  
**Performance Goals**: language changes should rebuild the visible UI within a single user interaction flow without resetting screen state.

- **Measurement Guidance (Goal, not hard gate)**: aim to display the visible UI update within ~300ms (p95) on representative devices and to keep the user flow under 3 interactions from Settings to visible UI update. Because CI and emulators vary, treat this as a performance goal measured during device-based integration tests or dedicated perf runs rather than a strict CI gate. Document the measurement harness (device class, emulator settings, warm/cold app state) in `specs/001-i18n/perf.md` before enforcing a numeric threshold.

**CI & Quality Enforcement Note**: The CI workflow (see T019) must run `flutter format`/lint and `flutter analyze` in addition to tests; coverage measurement should be documented and a recommended coverage threshold included in `plan.md` when the team decides on a target. Initially, CI will collect coverage reports but treat enforcement as a follow-up task until a project-wide threshold is agreed.
**Constraints**: preserve current converter inputs, selected currencies, favorites, and browsing position; default to device locale when supported; fall back cleanly for missing translations; ship English plus both Chinese variants at launch; keep the locale registry extensible for future languages  
**Scale/Scope**: small-to-medium Flutter app with shared screens, localized navigation, settings, converter, encyclopedia, and release-note text

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Test-first is required for the P1 language-switch flow and persistence behavior.
- User-facing localization must cover the visible app surfaces called out in the spec and remain consistent across screens.
- The work stays within the current app structure and does not introduce new services or storage systems.
- No privacy, secret-handling, or security policy changes are introduced by the localization feature.

Status: PASS

## Project Structure

### Documentation (this feature)

```text
specs/001-i18n/
├── plan.md
├── research.md
├── data-model.md
└── quickstart.md
```

### Source Code (repository root)

```text
lib/
├── l10n/
│   ├── app_en.arb
│   ├── app_zh_Hans.arb
│   ├── app_zh_Hant.arb
│   └── README.md
├── main.dart
├── providers/
├── screens/
├── services/
└── widgets/

test/
├── integration/
├── unit/
└── widget/
```

**Structure Decision**: Keep localization in the existing Flutter app under `lib/l10n/`, wire the selected locale through the existing `AppState`/`MaterialApp` flow, and add tests in the current `test/` layout rather than creating a new app boundary.

## Complexity Tracking

No constitution violations require justification.

