# Content Localization: Currency Encyclopedia

Purpose: define the T020 plan for localizing the currency encyclopedia so FR-002 is satisfied using the current currency dataset.

## Current State

- The encyclopedia data now comes from `assets/data/fiat_currencies.json` through `CurrencyCatalogService`.
- That file already contains the base fields needed by the encyclopedia: `iso_code`, `name`, `symbol`, `regions`, and `description`.
- The app does not currently have a separate encyclopedia content service, so T020 should define the overlay model and the migration path before T021 implements it.

## Plan

Use `assets/data/fiat_currencies.json` as the canonical base dataset and layer locale-specific overlays on top of it.

The overlay model should be field-based, not full-record replacement:

- Base record: always loaded from `fiat_currencies.json`.
- Locale overlay: optional translated values keyed by ISO code.
- Merge rule: for each field, use the locale overlay value when present; otherwise fall back to English/base data.
- Merge location: resolve overlays inside `CurrencyCatalogService` while building the `Currency` objects already consumed by the encyclopedia screens.

Recommended overlay shape:

```json
{
	"locale": "zh_Hans",
	"entries": {
		"USD": {
			"name": "美元",
			"description": "..."
		},
		"JPY": {
			"name": "日元"
		}
	}
}
```

This keeps the base catalog stable while allowing translators to work only on the fields that actually need localization.

Recommended overlay file layout:

- `assets/data/fiat_currency_overlays/en.json`
- `assets/data/fiat_currency_overlays/zh_Hans.json`
- `assets/data/fiat_currency_overlays/zh_Hant.json`

Each overlay file should contain only the fields that differ from `fiat_currencies.json` for that locale.

## Data Model

- `FiatCurrencyBase`: the canonical currency record from `fiat_currencies.json`.
- `FiatCurrencyOverlay`: a locale-specific patch containing optional translated fields.
- `FiatCurrencyResolved`: the merged result shown in the encyclopedia UI.

Resolution rules:

- `iso_code` must match exactly.
- Missing overlay fields inherit from the base record.
- If a locale overlay file is missing entirely, the app uses the English/base record.
- If a translated field is missing within an overlay, the app falls back field-by-field to English/base.

## Migration / Ingest Plan

1. Treat the current `fiat_currencies.json` content as the English baseline.
2. Generate an English overlay stub only if the future pipeline needs a normalized export format.
3. Maintain empty or partial overlay files for `zh_Hans` and `zh_Hant`.
4. If a future export workflow is reintroduced, it should read `fiat_currencies.json` and emit overlay stubs with all ISO codes prefilled; the current repository keeps the overlay files manually maintained.
5. Keep overlay files small and translator-friendly by including only fields that differ from the base data.

## Risks And Decisions

- Replacing the base dataset with per-locale full copies would create unnecessary drift; the overlay model avoids that.
- Server-side translation fetch is out of scope for the current release because the rest of the app is already asset-driven and offline-friendly.
- Since the currency catalog is shared across the app, the overlay merge must happen in the same service layer that already resolves currencies.

## Acceptance Criteria For T020

- The plan names `assets/data/fiat_currencies.json` as the source of truth.
- The plan defines how locale overlays are merged with the base currency data inside `CurrencyCatalogService`.
- The plan specifies English fallback behavior for missing translated fields.
- The plan defines a migration/export path that T021 can implement without reworking the base catalog.
- The plan defines structured missing-content logging with a stable event name and fields (`surface`, `locale`, `currency`, `field`, `fallback`).
- The plan sets up T022 to validate locale-specific display and fallback behavior against the actual fiat currency dataset.

## Deliverables

- `specs/001-i18n/content-localization.md` updated with the overlay plan.
- T021 implementation scope for overlay assets under `assets/data/fiat_currency_overlays/` and manual maintenance of localized overlays.
- T022 test scope for resolved encyclopedia currency content and English fallback.
