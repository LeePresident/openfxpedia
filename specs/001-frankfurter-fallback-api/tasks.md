# Tasks: Frankfurter Primary Exchange Source

Each task is small and ownerable. Estimates assume a single developer working part-time; adjust as needed.

## Phase 0 — Research & Contracts

- [x] 1. Create `research.md` documenting Frankfurter endpoints, sample responses, rate-limits, and usage notes. — 4h
- [x] 2. Produce `contracts/frankfurter.json` and `contracts/legacy.json` with example responses. — 2h
- [x] 3. Confirm caching storage API and path used by the app (Hive or file). — 2h

## Pre-implementation (Test-First)

- [x] 0.1. Create contract tests for `FrankfurterProvider` parsing and schema validation (mocked HTTP responses). — 3h
- [x] 0.2. Write unit tests for fallback triggers (`unreachable`, `timeout`, `invalid-response`, `missing-rate`) using TDD. — 4h
- [x] 0.3. Add observability instrumentation: structured logs for `RateLookupAttempt` and metric counters for primary/fallback outcomes. — 3h
- [ ] 0.4. Add/verify CI quality gates for this feature: pre-implementation tests must pass before implementation tasks, and coverage threshold checks must fail the build when unmet. — 2h

## Phase 1 — Design & Data Model

- [x] 4. Define `ExchangeRate` model with `source`, `base`, `target`, `rate`, `timestamp`, `raw_payload`. — 3h
- [x] 5. Draft `ExchangeProvider` interface and error enums. — 3h
- [x] 6. Review and merge `data-model.md`. — 1h

## Phase 2 — Implementation

- [x] 7. Implement `frankfurter_provider.dart` adapter scaffold (parsing + mapping). — 6h
- [x] 8. Implement `exchange_service.dart` orchestration with fallback rules. — 8h
- [x] 9. Persist rate metadata (source + timestamp) in cache. — 3h
- [x] 10. Add small UI indicator showing the source in conversion details. — 4h

## Phase 3 — Testing & Validation

- [x] 11. Unit tests for `FrankfurterProvider` parsing. — 3h
- [x] 12. Unit tests for fallback triggers and orchestration. — 4h
- [ ] 13. Integration test: end-to-end primary→fallback flow. — 6h
- [ ] 13.1. Integration/UI test: when both sources fail, show friendly error and preserve user-entered values. — 4h
- [x] 13.2. Performance validation: add spot microbenchmark/regression check for conversion flow p95 <= 2s on target devices. — 3h

## Phase 4 — Docs & Release

- [ ] 14. Update `quickstart.md` / `CHANGELOG.md` with behavior and rollout notes. — 2h
- [ ] 15. Prepare PR, include screenshots and testing notes. — 2h

## Dependencies & Order

- Pre-implementation tests (Tasks 0.1–0.3) MUST complete before any implementation tasks (7–10).
- CI quality gates task (Task 0.4) MUST complete before implementation tasks (7–10) and remain enabled for all validation tasks (11–13.2).
- Tasks 1–3 must complete before Task 5 and Task 7.
- Task 5 (interface) should be completed before Task 7 and Task 8.
- Testing (Tasks 11–13) depends on implementation tasks 7–10, but the test-first tasks above are blocking prerequisites.

## Owners

- Assign owners when creating the PR. Default owner: repository maintainer if unspecified.
