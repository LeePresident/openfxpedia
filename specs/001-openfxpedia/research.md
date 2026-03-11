# Research & Decisions — Currency Converter

This document records decisions for `specs/001-openfxpedia` required before implementation.

R0.1 Image sourcing
- Decision: Bundle a permissively-licensed icon set (SVG/PNG) with the app; do not fetch images at runtime.
- Rationale: Simplifies licensing, reduces runtime failures, and ensures offline availability.
- Alternatives considered: Runtime fetch from Wikimedia/CDN (rejected due to licensing uncertainty and network fragility).
- Actions: Add asset pipeline task (`T019`) and include icons at `apps/currency_converter/assets/icons/`.

R0.2 Cache strategy
- Decision: Use Hive for local persistence of rates, currency metadata, and favorites.
- Rationale: Hive is lightweight, cross-platform (Windows + Android), and simple to use from Flutter.
- Schema (high level):
  - `rates` store: key `base|target`, value `{ rate, timestamp, source }`
  - `currencies` store: key `iso_code`, value `Currency` entity with `icon_asset`
  - `prefs` store: favorites list, default currency, `rate_ttl_hours`
- TTL: default = 12 hours; manual refresh overrides TTL.
- Actions: Implement `cache_service` (T009) with TTL enforcement and cache-age metadata for UI.

R0.3 Rate refresh & background policy
- Decision: Refresh on app open, automatic background refresh every 12 hours, and manual refresh on user request.
- Rationale: Balances freshness vs battery/network usage; matches user expectation in spec.
- Actions: Implement background scheduler (T031) with platform-appropriate tooling (`workmanager` or foreground-check fallback on Windows).

R0.4 Image rendering & asset format
- Decision: Use SVG icons where available and fall back to PNG; use `flutter_svg` for SVG rendering.
- Rationale: SVG scales crisply across screen densities; fallback PNG for platforms lacking certain SVG support.
- Actions: Add `flutter_svg` to `pubspec.yaml` and asset entries in `pubspec.yaml`.

R0.5 Exchange API contract
- Decision: Use the public exchange-api endpoints for rate lookups; map responses to `ExchangeRate` entity.
- Rationale: User-specified data source; stable JSON shapes expected from the repository.
- Contract (example):
  - Request: `GET /v1/{base}.json` or `GET /v1/latest.json?base={base}` (confirm exact endpoints during implementation)
  - Response shape: `{ "rates": { "USD": 1.234 }, "date": "2026-03-09" }` → map to `{ base_currency, target_currency, rate, timestamp, source }`
- Actions: Add `contracts/exchange-rate.json` (T032) with example responses; implement defensive parsing in `exchange_client` (T008).

Open questions (deferred):
- Curated icon selection: pick a permissively-licensed pack (candidate: OpenMoji or custom minimal set). Verify license compatibility.
- Exact exchange-api endpoint variants: confirm during `T008` when implementing the client.

Signed-off-by: automation agent
