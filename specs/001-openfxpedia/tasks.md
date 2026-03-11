---
description: "Generated task list for Currency Converter & Encyclopedia"
---

# Tasks: Currency Converter & Encyclopedia

**Input**: `spec.md`, `plan.md`, (research/data-model/contracts if present)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Create Flutter project scaffold at apps/currency_converter (Windows + Android)
- [X] T002 Initialize `pubspec.yaml` with dependencies: `flutter`, `http`, `hive`, `hive_flutter`, `path_provider`, `provider`, `flutter_svg`, `intl` (pubspec.yaml)
- [X] [P] T003 Configure linting and formatting: analysis_options.yaml and .gitignore
- [X] [P] T004 Add basic CI workflow for Flutter (/.github/workflows/flutter.yaml) — CI must enforce linting and require tests for P1 features before merge

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before user stories

 - [X] T005 Create `research.md` documenting image sourcing (bundled icons), cache policy, rate refresh decisions, and background refresh approach (specs/001-openfxpedia/research.md)
 - [X] [P] T006 Create `data-model.md` with `Currency`, `ExchangeRate`, `UserPreference` entities (specs/001-openfxpedia/data-model.md)
- [X] [P] T007 Add `lib/models/currency.dart` and `lib/models/exchange_rate.dart` (lib/models/)
- [X] [P] T008 Implement exchange API client with rate fetch, fallback, and parsing at `lib/services/exchange_client.dart`
- [X] [P] T009 Implement local caching service (Hive) at `lib/services/cache_service.dart`
- [X] T010 Add app configuration & constants at `lib/core/config.dart`

- [X] T010a Test-first for US1: Author unit and integration tests for US1 (converter) before implementing production code (test/unit/conversion_test.dart)

- [X] T039 [P] Implement first-run currency picker dialog and wire into app startup (lib/main.dart)

- [ ] [P] T031 Implement background refresh scheduler (workmanager for Android / foreground-check for Windows) at `lib/services/refresh_scheduler.dart`
- [ ] T032 Create `contracts/exchange-rate.json` and `contracts/currency-catalog.json` examples (specs/001-openfxpedia/contracts/)
- [ ] T033 Add quickstart.md and developer notes at `specs/001-openfxpedia/quickstart.md`
- [ ] T034 [META] Update agent context with Flutter + Hive + exchange-api entries (specs/001-openfxpedia/agent-context-update.md)

**Checkpoint**: Foundation complete — user stories may begin

---

## Phase 3: User Story 1 - Quick Conversion (Priority: P1) 🎯 MVP

**Goal**: Allow fast conversions between selected currencies with visible rate timestamp and offline fallback

**Independent Test**: Open app, select source+target currencies, enter amount, observe converted amount and rate timestamp (or cached indicator if offline)

- [X] [P] T011 [US1] Create converter screen UI at `lib/screens/converter_screen.dart`
- [X] [P] T012 [US1] Create amount input widget at `lib/widgets/amount_input.dart`
- [X] T013 [US1] Implement conversion service `lib/services/conversion_service.dart` (uses `exchange_client` + `cache_service`)
- [X] T014 [US1] Add rate info widget showing timestamp and source at `lib/widgets/rate_info.dart`
- [X] T015 [US1] Wire converter UI to conversion service and cache fallback (lib/screens/converter_screen.dart + lib/providers/app_state.dart)
- [X] T016 [US1] Add unit tests for conversion math and parsing at `test/unit/conversion_test.dart`

**Checkpoint**: US1 should be independently functional and testable

---

## Phase 4: User Story 2 - Currency Encyclopedia (Priority: P2)

**Goal**: Browse currency metadata, view images and details for each currency

**Independent Test**: Open encyclopedia, view a currency entry, verify image (or placeholder), ISO code, name, regions, and description

- [X] T017 [US2] Create encyclopedia list screen at `lib/screens/encyclopedia_screen.dart`
- [X] [P] T018 [US2] Create currency detail screen at `lib/screens/currency_detail_screen.dart`
- [ ] [P] T019 [US2] Add asset pipeline and include bundled currency icons at `assets/icons/` and expose `icon_asset` lookup in `Currency` model
 - [X] T040 [US2] Add conversion choice dialog in currency detail screen to set From/To and switch to converter (lib/screens/currency_detail_screen.dart)
- [X] T020 [US2] Implement search and filter UI at `lib/widgets/search_bar.dart`
- [X] T021 [US2] Load currency metadata from CDN JSON and map to `Currency` entities at `lib/services/currency_catalog.dart`
- [ ] T022 [US2] Add integration test for encyclopedia flow at `test/integration/encyclopedia_flow_test.dart`

**Checkpoint**: US2 should be independently functional and testable

---

## Phase 5: User Story 3 - Manage Favorites & Search (Priority: P3)

**Goal**: Allow users to favorite currencies and use them as quick selections in the converter

**Independent Test**: Add/remove favorites, search, and use favorites from converter quick-select

- [X] [P] T023 [US3] Implement favorites storage service at `lib/services/favorites_service.dart`
- [X] T024 [US3] Add favorites UI component for quick-select at `lib/widgets/favorites_bar.dart`
- [X] T025 [US3] Integrate favorites with converter and encyclopedia UIs (lib/)
- [ ] T026 [US3] Add unit tests for favorites behavior at `test/unit/favorites_test.dart`

---

## Phase N: Polish & Cross-Cutting Concerns

- [P] [ ] T027 Update `README.md` and create `quickstart.md` with Windows + Android run instructions (specs/001-openfxpedia/quickstart.md)
- [P] [ ] T028 Add localization support and accessibility checks (apps/currency_converter/lib/l10n/)
- [P] [ ] T029 Performance tuning: caching TTLs, image sizes, and memory usage (apps/currency_converter/lib/)
- [P] [ ] T030 Produce release builds for Windows and Android and add build scripts (scripts/build_windows.ps1, scripts/build_android.sh)

- [ ] [P] T036 Define performance benchmark for conversion p95 ≤ 2s and produce `specs/001-openfxpedia/perf.md` with measurement procedure; include a simple microbenchmark harness and CI job definition.

- [ ] [P] T038 Define deprecated-currency handling rule: how to exclude or flag deprecated/withdrawn ISO codes, update cadence and reconciliation steps (specs/001-openfxpedia/deprecated_policy.md)
- [ ] T037 Implement a simple microbenchmark harness for conversion flow and add a CI job to run it and fail on regressions

---

## Dependencies & Execution Order

- Setup (Phase 1) → Foundational (Phase 2) → User Stories (Phase 3+) → Polish
- User stories MUST only start after Foundational phase completes
- Many tasks marked `[P]` can be implemented in parallel (separate files/services)

## Notes

- Tasks follow the required checklist format: `- [ ] T### [P?] [US?] Description with file path`
- IDs are sequential for execution order and traceability
- MVP suggestion: deliver only Phase 1 + Phase 2 + Phase 3 (US1)
