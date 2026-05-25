# Research: Frankfurter API

Purpose: gather technical details for integrating Frankfurter as the primary exchange-rate provider and document differences vs the existing provider.

1. Overview
 - Public API: https://www.frankfurter.app/ (no API key required for typical use).  
 - Supports latest rates, historical queries, and a currency list.

2. Key Endpoints
 - `GET /latest?from={BASE}&to={TARGET[,TARGET...]}` — latest rates for one or more targets.  
 - `GET /{DATE}?from={BASE}&to={TARGET[,TARGET...]}` — historical rates for a specific date (ISO yyyy-mm-dd).  
 - `GET /currencies` — list of supported currency codes & names.

3. Example Responses
 - Latest, single pair:

```json
{
  "amount": 1.0,
  "base": "USD",
  "date": "2026-05-07",
  "rates": { "EUR": 0.92 }
}
```

 - Latest, multiple targets:

```json
{
  "amount": 1.0,
  "base": "USD",
  "date": "2026-05-07",
  "rates": { "EUR": 0.92, "GBP": 0.79 }
}
```

4. Error Modes & Observations
 - No API key: endpoints are public; service may enforce rate limits or IP-based throttling.
 - Typical failures: network unreachable, HTTP 5xx from provider, empty `rates` for unusual currency pairs.
 - Invalid parameters return HTTP 4xx (bad request) with an error message.

5. Rate Limits & Etiquette
 - No documented per-client key limits; respect public API by caching results and avoiding frequent polling.  
 - Use app-level caching and background refresh policy (per spec: on open + periodic background refresh).  

6. Migration Considerations vs existing provider
 - Response shape differs slightly from legacy provider (Frankfurter uses `date` and `amount` fields; legacy uses `timestamp` and `source`). Map fields into a normalized `ExchangeRate` model.  
 - Normalize timestamps to UTC ISO-8601 in the app when persisting.  

7. Security & Privacy
 - No credentials required. Use HTTPS only. Do not log raw payloads containing sensitive environment information.

8. Tests to add for Phase 0 validation
 - Parse `/latest` single and multi-target responses successfully.  
 - Simulate HTTP 5xx, timeouts, and empty `rates` to ensure fallback triggers.  
 - Validate date/historical endpoints return expected shapes.

9. Next steps (Phase 0 deliverables)
 - Add `contracts/frankfurter.json` (sample + schema).  
 - Add `contracts/legacy.json` with example response shape used by current provider.  
 - Confirm exact cache API used in the app (Hive vs file) and path for persisted rates.
