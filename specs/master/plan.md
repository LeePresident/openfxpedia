# Implementation Plan — Currency Converter

## Technical Context
- Platforms: Flutter (Windows, Android)
- Language: Dart/Flutter
- Exchange rates API: https://github.com/fawazahmed0/exchange-api (fiat currencies in circulation)
- Currency list source: https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json (use all non-deprecated ISO 4217 currencies)
- Primary features: conversion UI, currency encyclopedia with images, offline caching, favorites

### Known Constraints
- Initial targets: Windows desktop and Android mobile.
- Use only the fiat currencies provided by the chosen exchange API / currency list.

### Unknowns / NEEDS CLARIFICATION
- Desired offline caching retention and sync policy (NEEDS CLARIFICATION)

Note: Image sourcing decision finalized — use bundled SVG/PNG icon assets included in the app (no runtime fetching). This avoids runtime licensing and availability issues.

-## Constitution Check
- Repository conventions: specs under `specs/master` (matches existing layout)
- Gate: platform support (Windows + Android) — satisfied by Flutter target

## Gates
- No blocking gates identified. Any unresolved NEEDS CLARIFICATION must be addressed before implementation steps that depend on them.

## Foundation Additions
To align with the project's constitution (test-first, accessibility, observability), the following cross-cutting tasks are included in the Foundational phase:

- Accessibility checks and basic automated accessibility tests (`T045`) — run during CI on supported platforms.
- Observability and structured logging (`T046`) — implement minimal metrics and logs to support performance measurements and production diagnostics.

These items are required before shipping P1 features to ensure compliance with quality gates.

---

## Phase 0 — Research & Decisions (produce `research.md`)
Tasks:
- Resolve image sourcing: research Wikimedia / Open-source icon sets and determine licensing.
- Define offline cache strategy: TTL, size limits, and persistence mechanism (SQLite / Hive / shared_preferences).
- Decide image caching approach and library (e.g., `cached_network_image`).
- Decide how to fetch exchange rates (endpoints, rate refresh cadence, error handling and fallback).

Format for each decision in `research.md`:
- Decision: [chosen option]
- Rationale: [why]
- Alternatives considered: [list]

Output: `research.md` with all NEEDS CLARIFICATION resolved.

## Resolved Clarifications (authoritative)
Decisions are centralized in `spec.md` and `research.md` to avoid duplication. For the definitive answers on image sourcing, supported currency set, rate refresh policy, and other policy choices, see:

 - `specs/master/spec.md`
 - `specs/master/research.md`

This `plan.md` references those documents as the single source of truth; do not duplicate decision text here. If you need to dispute or amend a decision, update `research.md` and record the rationale there.

## Design Decisions
- Storage: use Hive for local structured caching (rates, currency metadata, favorites) — lightweight and works on Windows + Android.
- HTTP client: use `http` package with retries/backoff for transient errors; parse JSON with built-in `dart:convert` and defensive validation.
- Image handling: use bundled SVG/PNG icon set (e.g., permissive icon pack) and `flutter_svg`/`Image` widgets for rendering.
- State management: `provider` for simple app state (conversions, catalog, favorites); structure code to allow later migration to Riverpod or Bloc.
- Background refresh: schedule with `workmanager` plugin for Android and platform-specific approach for Windows (periodic task on app foreground if OS background not available).

## Detailed Phase 0 Tasks (research.md)
- R0.1 Research icon packs that cover currency symbols and country flags; record license and size impact.
- R0.2 Define Hive schema for caching: `rates` (base,target,rate,timestamp), `currencies` (iso,name,symbol,meta), `favorites`.
- R0.3 Define rate refresh TTLs: default TTL = 12 hours, manual override per user preference.
- R0.4 Document API endpoints to use from exchange-api and expected JSON shapes (add to contracts/).
- R0.5 Produce `research.md` with Decision / Rationale / Alternatives for each item.

## Implemented Decisions
- Initial currency selection: show a mandatory first-run picker to choose `From` and `To` currencies. This reduces surprise defaults and ensures users start with meaningful values.
- Conversion choice dialog: from the currency detail screen, prompt whether the selected currency should fill the `From` or `To` field and then navigate to the converter.

## Phase 1 — Design & Contracts (expanded)
1) Data model (`data-model.md`)
 - Currency: {
	 - `iso_code` (string, primary),
	 - `name` (string),
	 - `symbol` (string|null),
	 - `decimal_digits` (int|null),
	 - `regions` (string[]),
	 - `description` (string|null),
	 - `icon_asset` (string|null)
 }
 - ExchangeRate: {
	 - `base_currency` (string),
	 - `target_currency` (string),
	 - `rate` (decimal),
	 - `timestamp` (ISO-8601),
	 - `source` (string)
 }
 - UserPreference / Favorites: {
	 - `favorites` (string[] of iso_codes),
	 - `default_currency` (string),
	 - `rate_ttl_hours` (int)
 }

2) Contracts (`/contracts/`)
 - `exchange-rate.json` (example response with fields above)
 - `currency-catalog.json` (mapping from CDN currencies.json to `Currency` entity)

3) Quickstart (`quickstart.md`) — minimal local dev steps:
 - Install Flutter SDK (stable, >=3.0)
 - `cd apps/currency_converter`
 - `flutter pub get`
 - `flutter run -d windows` (or `-d emulator-xxx` for Android)

## Architecture & Implementation Notes
- Project layout suggestion:
	- `apps/currency_converter/` — Flutter app
	- `apps/currency_converter/lib/models/` — data models
	- `apps/currency_converter/lib/services/` — exchange client, cache, image, favorites
	- `apps/currency_converter/lib/screens/` — UI screens
	- `specs/master/` — research, data-model, contracts, tasks
    
## Fiat Assets & Canonical Source
The authoritative source for supported currencies is the CDN JSON at `https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json`. The repository keeps a curated local asset `assets/data/fiat_currencies.json` used to whitelist and enrich supported currencies in the app.

Action: treat the CDN JSON as the canonical source and derive or validate `assets/data/fiat_currencies.json` from it. Add a validation step to the pipeline (or a maintenance task) that reconciles the local asset with the CDN on change or before release.
- Error handling: show Toast/Snackbar for transient errors; dedicated error page for catastrophic failures.
- Time handling: store timestamps as UTC ISO-8601; display localized relative time and absolute timestamp on rate info.

## Testing & CI
- Unit tests: conversion math, rate parsing, cache behavior.
- Widget tests: converter screen flows and encyclopedia list/detail.
- Integration tests: mock exchange API responses and verify offline fallback.
- CI: GitHub Actions workflow to run `flutter analyze`, `flutter test`, and build for Windows (optional) on push.

## Timeline & Estimates (rough)
- Phase 1 (setup + foundational models/services): 2–4 days
- US1 (Converter MVP): 3–5 days
- US2 (Encyclopedia): 4–7 days
- US3 (Favorites + polish): 2–3 days
- Total MVP timeline: ~2–3 weeks (single developer) — adjust for parallel work and QA time

## Acceptance Criteria Mapping
- US1 tasks (T011–T016) → must pass unit tests and manual UX test (conversion within 2 steps, timestamp shown)
- US2 tasks (T017–T022) → must display metadata and icon for entries and pass integration test
- US3 tasks (T023–T026) → favorites persistence across restarts and quick-select integration

## Next Steps (immediate)
1. Generate `research.md` entries (R0.1–R0.5) and commit.
2. Scaffold Flutter app skeleton at `apps/currency_converter` with `pubspec.yaml` and minimal `main.dart`.
3. Implement Hive models and exchange client skeleton.
4. Implement US1 UI and wire conversion service; run local manual test.

Priority note: Mark T019 (asset pipeline and bundled icons) and T036 (performance benchmark definition + microbenchmark) as high-priority for the next sprint.

---

---

## Phase 1 — Design & Contracts
Prerequisite: `research.md` complete

1) Data model (`data-model.md`)
- Entities: `Currency` (code, name, symbol, decimal_digits, image_url, category), `ExchangeRate` (base, quote, rate, timestamp), `Favorite` (currency_code, note)
- Validation rules: ISO 4217 code required; rate > 0; timestamp present.
- Relationships: `ExchangeRate` linked to `Currency` by code.

2) Interface contracts (`/contracts/`)
- If app exposes a plugin or public API, define JSON schema for exchange responses and for encyclopedia entries.
- Document minimal REST client contract used internally to call the exchange API.

3) Quickstart (`quickstart.md`)
- Minimal steps to run the app locally on Windows and Android (Flutter SDK version, required env vars, example commands).

4) Agent context update
- Run `.specify/scripts/powershell/update-agent-context.ps1 -AgentType copilot` to add new tech to agent context (Flutter, exchange-api, currency list URL).

Output: `data-model.md`, `/contracts/*`, `quickstart.md`, updated agent context file.

---

## Phase 2 — Implementation Plan (high level tasks)
- Scaffold Flutter app (multi-platform) with package layout and sample screens
- Implement exchange API client with rate caching and refresh logic
- Build conversion UI: selection, amount input, result display, history
- Build encyclopedia UI: list of currencies, detail page with image and metadata
 - Implement image asset pipeline for bundled icons & caching strategy
- Add offline cache & favorites
- Testing: unit tests for client and conversion logic, widget tests for UI flows
- Produce build artifacts for Windows and Android; write README and deployment notes

---

## Outputs & Files to Generate
- `research.md` (Phase 0)
- `data-model.md` (Phase 1)
- `/contracts/` (Phase 1)
- `quickstart.md` (Phase 1)
- Implementation artifacts (Flutter project scaffold and source files)

## Notes
- This is a draft `plan.md`. I marked image sourcing and offline policy as NEEDS CLARIFICATION so we can resolve them in `research.md` before coding.
