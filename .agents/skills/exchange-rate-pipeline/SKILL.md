---
name: exchange-rate-pipeline
description: 'Change or debug OpenFXpedia exchange-rate behavior. Use when editing providers, HTTP parsing, API source selection, automatic fallback, cached rates, refresh behavior, source attribution, conversion errors, or exchange observability.'
argument-hint: '[provider, failure mode, or conversion behavior]'
---

# Exchange-Rate Pipeline

Treat provider fetching, fallback orchestration, caching, and displayed rate metadata as one contract.

## Pipeline

- `lib/services/exchange_provider.dart` defines the provider boundary and rate snapshot contract.
- `lib/services/frankfurter_provider.dart` adapts the primary provider.
- `lib/services/exchange_client.dart` applies automatic or forced provider selection and records attempts.
- `lib/services/conversion_service.dart` chooses compatible cached data, performs conversion, and preserves source metadata.
- `lib/services/cache_service.dart` persists rates, UTC timestamps, and source identifiers.
- `lib/providers/app_state.dart` coordinates user preference, concurrent requests, errors, and visible state.
- Rate information widgets must display the source, timestamp, and cached status represented by the result.

## Change Procedure

1. Identify which layer owns the requested behavior. Keep provider-specific parsing inside its adapter and fallback policy inside `ExchangeClient`.
2. Preserve lowercase keys at provider and cache boundaries; UI-facing currency codes may remain uppercase.
3. Treat an unreachable provider, timeout, invalid response, or missing requested rate as a failure eligible for automatic fallback.
4. Do not silently fall back when the user explicitly selected one provider. A forced source either succeeds or reports that source's failure.
5. Return a snapshot only when it contains the requested target rate. Preserve the provider's quote timestamp and stable source identifier.
6. Record success, failure, and missing-rate attempts through `ExchangeObservability` without logging sensitive or full response data.
7. Cache source metadata with each rate snapshot. A fresh cache entry is reusable only when it matches the selected source policy and contains the requested target.
8. When live providers fail, allow compatible cached data even when stale. Mark the result as cached and retain its original timestamp and source when known.
9. Preserve current input and ignore stale asynchronous conversion responses when requests overlap.
10. Keep user-visible errors localized and avoid exposing raw transport or parsing exceptions.

## Focused Validation

Start with the layer changed:

```powershell
flutter test test/unit/frankfurter_provider_test.dart
flutter test test/unit/exchange_client_primary_fallback_test.dart
flutter test test/unit/conversion_test.dart
```

For source labels, settings, error presentation, or `AppState` changes, also run the nearest widget tests and then:

```powershell
flutter analyze
flutter test
```

Provider tests must use mocked HTTP clients or provider fakes. Do not make public network availability part of the automated test contract.
