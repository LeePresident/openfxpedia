# Implementation Tasks: Multi-Language App Support

Phase 1: Setup

- [X] T001 [P] Create initial English ARB file at lib/l10n/app_en.arb with primary UI keys and values (file: lib/l10n/app_en.arb)
- [X] T002 [P] Create Simplified Chinese ARB file at lib/l10n/app_zh_Hans.arb with matching keys (file: lib/l10n/app_zh_Hans.arb)
- [X] T003 [P] Create Traditional Chinese ARB file at lib/l10n/app_zh_Hant.arb with matching keys (file: lib/l10n/app_zh_Hant.arb)
- [X] T004 Create `l10n.yaml` at project root to configure Flutter gen_l10n (file: l10n.yaml)
- [X] T005 [P] Add `lib/l10n/README.md` describing ARB key conventions and how to add new locales (file: lib/l10n/README.md)

Phase 2: Foundational (blocking prerequisites)

- [X] T006 Update `lib/core/config.dart` to add a `localeKey` constant used for persistence (file: lib/core/config.dart)
- [X] T007 Add explicit locale load/save helpers to `lib/services/cache_service.dart`: implement `Future<void> setLocaleCode(String?)` and `String? getLocaleCode()` (file: lib/services/cache_service.dart)
- [X] T008 Add locale state and persistence to `lib/providers/app_state.dart` and expose `Locale? locale`, `Future<void> setLocale(Locale?)`, `_loadLocale()` (file: lib/providers/app_state.dart)
- [X] T009 Wire `MaterialApp.locale` and `supportedLocales` in `lib/main.dart` to use `AppState.locale` and include `Locale('en')`, `Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans')`, and `Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')` (file: lib/main.dart)

Phase 3: User Story 1 — Switch Language Manually (Priority: P1)

- [X] T009A [TEST-FIRST] [P] Write failing P1 widget test for language-switch flow (Settings → select language → UI updates immediately; selection persisted across restart). This test should be authored before implementation and may mock persistence to assert the desired behavior; once failing test exists, implement T006–T009 to make it pass. (file: test/widget/locale_switch_p1_test.dart)
- [X] T010 [US1] [P] Add language selection UI entry in Settings: show current language and open a dialog to pick English / Simplified Chinese / Traditional Chinese (file: lib/screens/settings_screen.dart)
- [X] T011 [US1] Implement the dialog action to call `AppState.setLocale(...)` and persist the choice (file: lib/screens/settings_screen.dart)
- [X] T012 [US1] Ensure changing the locale updates the visible UI without clearing inputs or navigation state (integrate with `AppState` and `MaterialApp`) (files: lib/providers/app_state.dart, lib/main.dart)

Phase 4: User Story 2 — Sensible Default (Priority: P2)

- [X] T013 [US2] On startup, detect device locales and apply the first supported locale (English / zh-Hans / zh-Hant) if user has not set a manual preference (file: lib/providers/app_state.dart)
- [X] T014 [US2] Add an acceptance test that simulates first-run device locale and verifies the app starts in the matching language (file: test/widget/locale_startup_test.dart)

Phase 5: User Story 3 — Fallback & Partial Coverage (Priority: P3)

- [X] T015 [US3] Ensure generated localization configuration falls back to English for missing keys. Add structured logging/metrics for missing-key occurrences (debug builds) and an optional in-app debug overlay to list missing keys. Acceptance: missing-key events are emitted as structured logs and a unit/widget test verifies fallback behavior for both UI strings and content assets. (files: l10n.yaml, lib/main.dart, lib/services/observability.dart)
- [X] T016 [US3] Add a widget test that loads a partly-populated ARB for a locale and verifies missing strings show English fallback (file: test/widget/locale_fallback_test.dart)

Phase 6: Polish & Cross-Cutting Concerns

- [X] T017 [P] Add localization keys for release notes/changelogs and update the changelog-fetch UI to use localized strings where applicable (files: lib/screens/settings_screen.dart, lib/l10n/*.arb)
- [X] T018 [P] Update README and `specs/001-i18n/quickstart.md` with the exact add-locale steps (file: README.md, specs/001-i18n/quickstart.md)
- [X] T019 [P] Add CI step: run `flutter pub get` and `flutter test` in CI for locale tests. Create or update workflow at `.github/workflows/ci.yml` to include localization tests. (file: .github/workflows/ci.yml)

Content Localization (CRITICAL - addresses FR-002)

- [X] T020A [P] Inventory the current encyclopedia currency pipeline in `lib/services/currency_catalog.dart`, `lib/models/currency.dart`, and `assets/data/fiat_currencies.json` so the plan reflects the actual fields available for localization. (files: lib/services/currency_catalog.dart, lib/models/currency.dart, assets/data/fiat_currencies.json)
- [X] T020B [P] Define the locale overlay schema in `specs/001-i18n/content-localization.md`, including the base record, translated field overlays, the `assets/data/fiat_currency_overlays/{en,zh_Hans,zh_Hant}.json` layout, and the merge/fallback rules for `en`, `zh_Hans`, and `zh_Hant`. (file: specs/001-i18n/content-localization.md)
- [X] T020C [P] Document the migration/export flow in `specs/001-i18n/content-localization.md`, including how to generate overlay stubs from `assets/data/fiat_currencies.json` and how translators should update localized currency fields for each overlay file. (file: specs/001-i18n/content-localization.md)
- [X] T020D [P] Define the acceptance criteria and verification checkpoints for localized currency info, including English fallback when an overlay field is missing and a structured missing-content event with `surface`, `locale`, `currency`, `field`, and `fallback`. (file: specs/001-i18n/content-localization.md)
- [X] T020E [P] Update the content-localization deliverables and implementation notes in `specs/001-i18n/content-localization.md` so T021 and T022 can consume the finalized plan without further scope changes. (file: specs/001-i18n/content-localization.md)
- [X] T021 [P] Implement the content localization pipeline per T020: add locale overlay assets under `assets/data/fiat_currency_overlays/` and keep the localized currency files manually maintained on top of `assets/data/fiat_currencies.json`. (files: assets/data/fiat_currencies.json, assets/data/fiat_currency_overlays/**)
- [X] T022 [P] Add tests that verify encyclopedia currency info is shown in the selected locale and falls back to English when locale-specific fields are missing. Include CI checks that verify the overlay assets exist for each supported locale or that fallbacks are correct. (file: test/widget/encyclopedia_locale_test.dart)

- Dependencies

- Write the failing P1 test (T009A) before implementation. Implement foundational tasks (T006-T009) after the failing test is authored so the test can be made to pass. US1 tasks (T010-T012) depend on T009A being authored and T006-T009 being implemented.
- Startup/default behavior (T013-T014) depends on T006-T009 being completed.
- Fallback behavior (T015-T016) depends on T001-T004 and T006-T009.

Parallel execution examples

- ARB file creation (T001, T002, T003) and `lib/l10n/README.md` (T005) are independent and can be done in parallel.
- Tests (T014, T016) can be written in parallel with implementation tasks once interfaces are stabilized.

Independent test criteria (per user story)

- US1 (Switch Language Manually): Can be validated by interacting with Settings → Language → select language → observe immediate UI update and persisted choice after restart.
- US2 (Sensible Default): Reset app state, simulate device locale, and verify the app starts in a supported language without manual choice.
- US3 (Fallback): Use a locale ARB with deliberately missing keys and verify that the UI shows English for missing values and remains usable.

Implementation strategy

- MVP: Implement `AppState` locale wiring, basic Settings language chooser, and ARB files for English + both Chinese variants. Provide tests covering the P1 flow and persistence.
- Incremental delivery: 1) Add ARB + l10n config, 2) Wire AppState + MaterialApp, 3) Add Settings UI and tests, 4) Add startup default detection and fallback tests, 5) Polish release-notes localization and CI.

Estimated task count: 19

Suggested next actions

- Start with T001–T005 (ARB + config) in parallel, then implement T006–T009 before UI tasks.
- I can now generate PR-ready patches for the top-priority tasks (T001–T009). Do you want me to start with those changes now?
