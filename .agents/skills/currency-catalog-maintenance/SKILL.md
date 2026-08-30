---
name: currency-catalog-maintenance
description: 'Maintain OpenFXpedia currency catalog data and visual identity. Use when adding, removing, or correcting fiat currencies, ISO numeric codes, symbols, regions, country flags, special currency icons, deprecated codes, catalog filtering, or bundled currency assets.'
argument-hint: '[ISO code or catalog change]'
---

# Currency Catalog Maintenance

The shipped fiat dataset defines which remote catalog entries the application exposes and enriches them with encyclopedia metadata.

## Data Contract

- `assets/data/fiat_currencies.json` is the canonical bundled fiat dataset and whitelist.
- `CurrencyCatalogService` intersects the remote currency catalog with that whitelist and resolves metadata.
- `Currency` carries ISO alpha and numeric codes, name, symbol, regions, region codes, and description.
- Locale overlays contain translated fields only. Use the `localization-update` skill when translation content changes.
- Region-to-country mappings drive flag rendering. Shared or supranational currencies may need an explicit mapping or a neutral fallback.

## Change Procedure

1. Confirm the currency is an active ISO 4217 fiat currency. Follow `specs/master/deprecated_policy.md` for withdrawn or replaced codes.
2. Add or update the base record without creating duplicate ISO alpha or numeric codes. Keep ISO alpha codes uppercase and numeric codes as zero-padded strings.
3. Preserve all required encyclopedia fields and the existing JSON shape. Do not infer a country flag solely from a translated region name.
4. Update the region mapping used by `lib/widgets/region_flag.dart` when a region needs a new or corrected country code.
5. Use `country_flags` for country and regional flags. Add a bundled SVG under `assets/icons/` only for currencies that need a project-authored currency-specific icon.
6. For any new asset, use a lowercase filename, document its origin and license, and add a precise `pubspec.yaml` asset entry when it is outside an already declared directory.
7. Keep base English metadata and locale overlays synchronized by ISO code, but do not copy full base records into overlays.
8. Check search behavior for name, alpha code, numeric code, and region when changing searchable fields.

## Validation

Validate JSON syntax before running Flutter tests. Then run:

```powershell
flutter test test/unit/currency_test.dart
flutter test test/unit/region_catalog_coverage_test.dart
flutter test test/unit/region_flag_test.dart
flutter test test/widget/encyclopedia_locale_test.dart
flutter analyze
```

For changes affecting list, detail, search, sorting, or favorites behavior, also run the corresponding widget and integration tests under `test/widget/` and `test/integration/`.

Review `specs/master/data/asset-conventions.md`, `specs/master/data/asset-licenses.md`, and `specs/master/deprecated_policy.md` before adding new data or artwork.
