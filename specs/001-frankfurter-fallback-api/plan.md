# Implementation Plan: Frankfurter Primary Exchange Source

**Branch**: `001-frankfurter-fallback-api` | **Date**: 2026-05-07 | **Spec**: `spec.md`
**Input**: Feature specification in `specs/001-frankfurter-fallback-api/spec.md`

## Summary

Switch the app to prefer the Frankfurter exchange-rate provider for live rates, and keep the existing provider as a fallback. Implement a provider adapter, fallback rules (unreachable, timeout, invalid, incomplete, or missing rate), source metadata on displayed conversions, and tests to validate fallback behavior and source visibility.

## Technical Context (initial)

- **Language/Platform**: Dart / Flutter (Windows + Android)
- **Primary Dependencies**: HTTP client used in app, caching (existing local storage), test framework (flutter_test)
- **Storage**: Existing cache mechanism (local file or Hive) — confirm exact API during Phase 0
- **Testing**: Unit tests with `flutter_test`, integration tests with existing integration harness
- **Performance Goals**: No visible latency regression vs current provider; p95 conversion flow <= 2s on target devices (as existing spec)

## Gates / Constitution Check

- Gate: Research must confirm Frankfurter response shapes and error modes and that no paid credentials are required.

- Gate: Per project constitution, P1 features require tests authored before implementation (Test-First). Pre-implementation contract/unit tests and basic observability instrumentation MUST be created and verified locally before implementation begins.

## Phases & Milestones

Phase 0 — Research & Contracts (2 days)
- Create `research.md` with Frankfurter API endpoints, sample responses, rate-limits, CORS/usage notes.
- Produce contract stubs under `contracts/` for Frankfurter and the existing provider.
- Confirm caching format and storage path for cached rates.

Milestone: `research.md` and `contracts/` created and reviewed.

Phase 1 — Pre-implementation Tests & Design (2–3 days)
- Write contract tests for `FrankfurterProvider` parsing and schema validation (mocked HTTP responses).
- Write unit tests for fallback triggers (`unreachable`, `timeout`, `invalid-response`, `missing-rate`) using a TDD approach.
- Add observability scaffolding: structured logs for `RateLookupAttempt` and metric counters for primary/fallback outcomes.
- Add explicit CI quality gates for this feature: pre-implementation tests must pass before implementation tasks begin, and coverage thresholds for new code must be enforced.
- Define `ExchangeRate` result model to include `source`, `base`, `target`, `rate`, `timestamp`, `raw_payload` (optional).
- Draft adapter interface `ExchangeProvider` (methods: `fetchLatest(base)`, `fetchPair(base, target)`) and failure/error enums.
- Update `data-model.md` and `quickstart.md` with usage examples.

Milestone: Pre-implementation tests and observability scaffolding complete; `data-model.md` and adapter interface approved.

Phase 2 — Implementation (3–5 days)
- Implement `FrankfurterProvider` adapter scaffold and map its responses to `ExchangeRate` model.
- Implement fallback orchestration in the service layer: attempt primary, on defined triggers attempt fallback, persist metadata.
- Add UI indicator in conversion detail (small label: "Source: Frankfurter" / "Source: fallback-provider").

Milestone: Feature branch includes adapter, orchestration, and UI indicator.

Phase 3 — Testing & Validation (2–3 days)
- Unit tests for adapter parsing, provider error modes, and fallback logic (unreachable, timeout, invalid, missing rate).
- Integration tests validating end-to-end primary→fallback flows and source visibility in UI tests.
- Performance spot checks and microbenchmarks to ensure no perceptible regressions and validate p95 conversion flow <= 2s on target devices.
- Validate user-facing double-failure behavior: friendly error message is shown and entered values remain intact.

Milestone: Tests pass locally; coverage for critical flows added.

Phase 4 — Docs, Release, and PR (1 day)
- Update `specs/.../quickstart.md`, `CHANGELOG.md`, and release notes describing the source change and fallback behavior.
- Prepare PR with testing notes, screenshots of UI indicator, and checklist for reviewers.

Milestone: PR opened and marked ready for review.

## Acceptance Criteria / Done Conditions

- The app uses Frankfurter responses for conversions when available in validation runs.
- When Frankfurter fails (per fallback triggers), the app returns results using the fallback provider.
- All conversion results include `source` metadata visible in the UI.
- Unit and integration tests cover fallback triggers and source visibility.
- Observability: `RateLookupAttempt` events are logged with structured fields and metrics for primary/fallback outcomes are emitted during validation runs.

## Risks & Mitigations

- Risk: Frankfurter response format or rate-limits are incompatible. Mitigation: Implement lightweight adapter and caching; fall back immediately on unexpected responses.
- Risk: UI changes clutter small screens. Mitigation: compact indicator (tooltip or small text) and include in acceptance testing.

## Artifacts to Produce

- `specs/001-frankfurter-fallback-api/research.md`
- `specs/001-frankfurter-fallback-api/contracts/frankfurter.json`
- `specs/001-frankfurter-fallback-api/data-model.md`
- `lib/services/exchange_provider.dart` (adapter interface)
- `lib/services/frankfurter_provider.dart` (adapter)
- `lib/services/exchange_service.dart` (orchestration)
- `specs/001-frankfurter-fallback-api/tasks.md`

## Owners & Estimates

- Author / Owner: TBD (assign when creating tasks)
- Phase 0: 2 days, Phase 1: 2–3 days, Phase 2: 3–5 days, Phase 3: 2–3 days, Phase 4: 1 day

## Next Steps

1. Run Phase 0: create `research.md` and contract stubs.  
2. Produce `data-model.md` and adapter interface.  
3. Implement adapters and fallback orchestration.  
4. Add tests and docs, then prepare PR.
