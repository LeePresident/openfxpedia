# Data Model: Frankfurter Primary Exchange Source

## Entities

### ExchangeSource

- `id`: Stable identifier for a rate provider, such as `frankfurter` or `legacy`.
- `displayName`: User-facing provider label shown in the conversion result.
- `role`: Whether the provider is the `primary` or `fallback` source for the current release.
- `supportsHistoricalRates`: Whether the provider can answer dated exchange-rate requests.

### ExchangeRateSnapshot

- `baseCurrency`: ISO currency code used as the source currency for the rate lookup.
- `quotedAt`: Normalized timestamp or date describing when the provider says the rate is current.
- `sourceId`: Identifier of the provider that supplied the rates.
- `rates`: Map of target ISO currency codes to numeric rate values.
- `retrievedAt`: Timestamp when the app received and stored the response.
- `isFallbackResult`: Whether the snapshot was returned only after the primary provider failed.

### ConversionRequest

- `baseCurrency`: ISO currency code selected by the user as the source currency.
- `targetCurrency`: ISO currency code selected by the user as the destination currency.
- `amount`: Numeric amount entered by the user.
- `requestedAt`: Timestamp when the conversion was requested.

### ConversionResult

- `baseCurrency`: ISO currency code used for the conversion.
- `targetCurrency`: ISO currency code produced by the conversion.
- `amount`: Original amount entered by the user.
- `convertedAmount`: Calculated output amount shown to the user.
- `rate`: Numeric rate applied to the conversion.
- `sourceId`: Identifier of the provider whose rate was used.
- `quotedAt`: Timestamp or date associated with the rate shown to the user.
- `isFallbackResult`: Whether the conversion used the fallback source.

### RateLookupAttempt

- `sourceId`: Identifier of the provider attempted for the lookup.
- `status`: Outcome of the attempt, such as `success`, `unreachable`, `timeout`, `invalid-response`, `missing-rate`, or `failed`.
- `startedAt`: Timestamp when the provider attempt began.
- `finishedAt`: Timestamp when the provider attempt completed.
- `failureReason`: Human-readable summary of the failure when the attempt does not succeed.

## Relationships

- `ConversionRequest` resolves to one `ConversionResult` using a rate selected from one `ExchangeRateSnapshot`.
- `ExchangeRateSnapshot` is always associated with one `ExchangeSource` through `sourceId`.
- `ConversionResult` references one `ExchangeSource` through `sourceId` and may be backed by one or more `RateLookupAttempt` records.
- A failed primary `RateLookupAttempt` may lead to a successful fallback `RateLookupAttempt` for the same `ConversionRequest`.

## Validation Rules

- `baseCurrency` and `targetCurrency` must be valid supported ISO currency codes and must not be blank.
- `amount` must be a finite numeric value greater than zero for a successful `ConversionResult`.
- `rates` must contain only finite numeric values greater than zero.
- `ConversionResult.sourceId` must match the `sourceId` of the `ExchangeRateSnapshot` used to calculate it.
- `isFallbackResult` must be `true` only when the selected rate came from the fallback source after a primary lookup failure.
- A primary lookup failure that triggers fallback must record a `RateLookupAttempt.status` of `unreachable`, `timeout`, `invalid-response`, `missing-rate`, or another explicit failure value.

## State Transitions

- `primary-attempt` -> `primary-success` when the primary source returns a usable rate for the requested currency pair.
- `primary-attempt` -> `fallback-attempt` when the primary source is unreachable, times out, returns invalid data, returns incomplete data, or does not provide the requested rate.
- `fallback-attempt` -> `fallback-success` when the fallback source returns a usable rate for the requested currency pair.
- `fallback-attempt` -> `conversion-error` when the fallback source also fails to provide a usable rate.
- `primary-success` -> `cached-display` when the returned snapshot is stored for later offline or retry use.
- `fallback-success` -> `cached-display` when the fallback snapshot is stored and shown with visible fallback provenance.