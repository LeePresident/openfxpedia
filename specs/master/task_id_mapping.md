# Task ID Mapping (old → new)

Generated: 2026-03-15

Purpose: Provide traceability between previously observed task occurrences and the canonical, normalized task IDs currently used in `specs/master/tasks.md`.

Notes:
- Most task IDs remain unchanged; this file records each canonical ID and flags duplicate occurrences or historical anomalies found in the file snapshot.
- If you want git-based historical mapping (from commits), I can generate a mapping from commit history next.

| Old occurrence (snippet) | Canonical ID | Notes |
|---|---:|---|

<!-- Phase 1 -->
| `T001 Create Flutter project scaffold at apps/currency_converter` | T001 | no change |
| `T002 Initialize \`pubspec.yaml\` with dependencies` | T002 | no change |
| `T003 Configure linting and formatting` | T003 | no change |
| `T004 Add basic CI workflow for Flutter` | T004 | no change |

<!-- Phase 2 -->
| `T005 Create \`research.md\` documenting image sourcing` | T005 | no change |
| `T006 Create \`data-model.md\` with Currency, ExchangeRate, UserPreference` | T006 | no change |
| `T007 Add \`lib/models/currency.dart\`` | T007 | no change |
| `T008 Implement exchange API client` | T008 | no change |
| `T009 Implement local caching service (Hive)` | T009 | no change |
| `T010 Add app configuration & constants` | T010 | no change |
| `T011 Implement background refresh scheduler` | T011 | no change (found in Phase 2) |
| `T012 Create contracts JSON examples` | T012 | no change |
| `T013 Add quickstart.md and developer notes` | T013 | no change |
| `T014 [META] Update agent context` | T014 | no change |
| `T015 Asset pipeline: license audit and manifest` | T015 | no change |
| `T016 Asset pipeline: naming conventions and mapping scheme` | T016 | no change |
| `T017 Asset pipeline: optimization & size budget` | T017 | no change |
| `T018 Asset pipeline: generate \`icon_asset\` mapping` | T018 | no change |
| `T019 Accessibility: add accessibility checklist` | T019 | no change |
| `T020 Observability: implement structured logging` | T020 | no change |

<!-- Phase 3 (US1) -->
| `T021 Create converter screen UI` | T021 | no change |
| `T022 Create amount input widget` | T022 | no change |

<!-- Duplicate occurrences noticed for T023..T026 in the file snapshot -->
| `T023 Implement conversion service` | T023 | Duplicate occurrence(s) present in file; canonical ID T023 (final state: implemented) |
| `T024 Add rate info widget showing timestamp` | T024 | Duplicate occurrence(s) present; canonical ID T024 (final state: implemented) |
| `T025 Wire converter UI to conversion service and cache fallback` | T025 | Duplicate occurrence(s) present; canonical ID T025 (final state: implemented) |
| `T026 Add unit tests for conversion math and parsing` | T026 | Duplicate occurrence(s) present; canonical ID T026 (final state: implemented) |

| `T027 Test-first for US1: Author unit and integration tests for US1` | T027 | no change |
| `T028 Implement first-run currency picker dialog` | T028 | no change |

<!-- Phase 4 (US2) -->
| `T029 Create encyclopedia list screen` | T029 | no change |
| `T030 Create currency detail screen` | T030 | no change |
| `T031 Add asset pipeline and include bundled currency icons` | T031 | no change |
| `T032 Add conversion choice dialog in currency detail screen` | T032 | no change |
| `T033 Implement search and filter UI` | T033 | no change |
| `T034 Load currency metadata from CDN JSON` | T034 | no change |
| `T035 Add integration test for encyclopedia flow` | T035 | no change |

<!-- Phase 5 (US3) -->
| `T036 Implement favorites storage service` | T036 | no change |
| `T037 Add favorites UI component for quick-select` | T037 | no change |
| `T038 Integrate favorites with converter and encyclopedia UIs` | T038 | no change |
| `T039 Add unit tests for favorites behavior` | T039 | no change |

<!-- Polish & Cross-Cutting -->
| `T040 Update README and create quickstart.md` | T040 | no change |
| `T041 Add localization support and accessibility checks` | T041 | no change |
| `T042 Performance tuning: caching TTLs, image sizes` | T042 | no change |
| `T043 Produce release builds for Windows and Android` | T043 | no change |
| `T044 Define performance benchmark and perf.md` | T044 | no change |
| `T045 Define deprecated-currency handling rule` | T045 | no change |
| `T046 Implement a simple microbenchmark harness` | T046 | no change |

---

How to use this file:
- Treat the "Canonical ID" column as the current source of truth.
- Duplicates found in `tasks.md` (noted above) should be de-duplicated once you confirm the intended final states; I can do that as a follow-up.
- If you want a git-history-based mapping (map commit ranges or prior filenames to new IDs), say so and I will generate it using `git log` and file diffs.

Would you like me to (select one):
- De-duplicate the repeated T023–T026 entries in `specs/master/tasks.md` and keep the canonical (checked) versions?
- Produce a CSV or JSON variant of this mapping for import into tooling?
- Generate a git-anchored historical mapping using commit history?
