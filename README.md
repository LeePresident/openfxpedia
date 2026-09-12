 # OpenFXpedia — Currency Converter & Encyclopedia

## Overview

OpenFXpedia is a lightweight Flutter application combining a currency converter with a searchable currency encyclopedia (flags, symbols, regions, and descriptions). The app targets Windows (desktop) and Android.

Current release: `1.0.3`

## Quick Links

- Spec & tasks: `specs/master`

## Architecture

The application keeps UI orchestration in providers and domain/data work in services:

- `CurrencyCatalogService` builds the localized `Currency` models used by the encyclopedia.
- `CurrencyCatalogRepository` owns remote catalog retrieval, cache persistence, TTL handling, and offline fallback.
- `CurrencyMetadataLoader` loads the bundled fiat whitelist and metadata from `assets/data/fiat_currencies.json`.
- `CurrencyOverlayLoader` loads locale-specific encyclopedia overlays from `assets/data/fiat_currency_overlays/`.
- `CurrencyLocalizer` applies overlay values and records field-level English fallback events.
- `CacheService` owns persisted rates, catalog data, favorites, and preferences through Hive.

The catalog loaders cache data within their service instance. The catalog service retains only the active localized currency list, while the repository preserves the existing cached and offline behavior.

## Features

- Fast currency conversion using live exchange rates (with local cache and offline support).
- Select the exchange-rate API source from Settings, with automatic primary/fallback behavior.
- Encyclopedia entries for fiat currencies: names, symbols, regions, descriptions, and usage-region flags.
- Search currencies by name, code, or ISO 4217 numeric code, with clear-search support.
- Light / Dark / System theme selection persisted in app settings.
- English, Simplified Chinese, and Traditional Chinese language selection in Settings.
- Favorites, quick-swap, and From/To chooser dialogs for fast workflows.
- In-app update checks open the device-specific GitHub release asset: `openfxpedia_<version>_setup.exe` on Windows and `openfxpedia_<version>.apk` on Android.

## Prerequisites

- Flutter SDK (stable channel)
- Windows: enable desktop support (`flutter config --enable-windows-desktop`)
- Windows release installer: NSIS (`makensis` must be on PATH)
- Android: Android SDK + emulator or device
- Recommended: run `flutter doctor` to verify environment

## Quickstart (Windows)

1. From repository root:

```powershell
flutter pub get
flutter run -d windows
```

## Quickstart (Android Emulator or Device)

```powershell
flutter pub get
flutter run
```

## Release Builds

```powershell
# Windows
./scripts/build_windows.ps1

# Portable EXE output (release)
# build/windows/portable/openfxpedia_<version>.exe

# NSIS installer output (release)
# build/windows/installer/openfxpedia_<version>_setup.exe

# Android (Windows PowerShell)
./scripts/build_android.ps1
./scripts/build_android.ps1 -Mode debug

# APK output (release)
# build/app/outputs/flutter-apk/openfxpedia_<version>.apk
# SHA1 output (release)
# build/app/outputs/flutter-apk/openfxpedia_<version>.apk.sha1
```

```bash
# Windows (Git Bash)
bash ./scripts/build_windows.sh
bash ./scripts/build_windows.sh debug

# Portable EXE output (release)
# build/windows/portable/openfxpedia_<version>.exe

# For the NSIS installer, use the PowerShell script above.

# Android (macOS/Linux/Git Bash)
bash ./scripts/build_android.sh
bash ./scripts/build_android.sh debug

# APK output (release)
# build/app/outputs/flutter-apk/openfxpedia_<version>.apk
# SHA1 output (release)
# build/app/outputs/flutter-apk/openfxpedia_<version>.apk.sha1
```

## Performance Benchmark

```powershell
dart run tool/conversion_benchmark.dart --samples 100 --threshold-ms 2000
```

## APIs and Data Sources

- Exchange rates (primary): https://github.com/lineofflight/frankfurter
- Exchange rates (fallback): https://github.com/fawazahmed0/exchange-api
- Currency list (ISO 4217): https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json

The app fetches live exchange rates from Frankfurter first and falls back to exchange-api only when the primary source is unavailable, times out, or cannot provide the requested rate. The CDN JSON remains the canonical source for currency metadata. The repository also maintains a curated whitelist asset at `assets/data/fiat_currencies.json` that ships with richer metadata used by the encyclopedia.

Users can toggle the exchange-rate API source in Settings by choosing automatic selection, Frankfurter, or exchange-api.

## Assets

- Store app branding under `assets/branding/` and encyclopedia data under `assets/encyclopedia/`.
- The encyclopedia uses `country_flags` for country and regional flags. Euro uses the European Union flag.
- The original project-authored icons for XAF, XCD, XCG, XOF, and XPF remain bundled as circular currency-specific icons.
- Ensure `pubspec.yaml` includes the asset entries before running the app.

Country flags in the encyclopedia use the [`country_flags`](https://pub.dev/packages/country_flags) Flutter package (MIT License). The package acknowledges the [`flag-icons`](https://github.com/lipis/flag-icons) project for the bundled SVG flag artwork.

## Testing

- Run unit/widget tests with:

```powershell
flutter test
```

- Run static analysis with:

```powershell
flutter analyze
```

- Run focused catalog and conversion checks with:

```powershell
flutter test test/widget/encyclopedia_locale_test.dart
flutter test test/integration/encyclopedia_flow_test.dart
flutter test test/unit/conversion_test.dart
```

## Localization Notes

- Update `lib/l10n/app_en.arb` first when adding a new string.
- Keep `lib/l10n/app_zh_Hans.arb` and `lib/l10n/app_zh_Hant.arb` aligned with the English key set.
- `lib/l10n/app_zh.arb` is the neutral Chinese fallback source for the `zh` locale family.
- `OpenFXpedia` is a product name and remains unchanged in every locale.
- Regenerate the checked-in localization output after ARB changes with `flutter gen-l10n`, then run `dart format lib/l10n`.

The startup screen is rendered by Flutter so its loading status and startup errors can use the selected locale. Windows keeps this Flutter-rendered screen visible while the app initializes; Android uses the native splash until Flutter is ready and then removes it.

## VS Code

- This repo includes `.vscode` launch and task configs to help run and debug the app on Windows and Android.
- If you use VS Code, open the workspace root and use the Run view to launch the app.

## Troubleshooting

- If desktop build fails: verify desktop support and Visual Studio (with C++ workload) are installed for Windows.
- If installer build fails: verify NSIS is installed and `makensis` is available in PATH.
- If Flutter cannot find devices: run `flutter doctor -v` and ensure Android SDK/emulator or Windows desktop is configured.
- For dependency issues: run `flutter pub get` and resolve pub errors.

## Contributing

- Open a branch for your work and submit a PR. For feature design and tasks see `specs/master`.
- When adding or updating currency metadata, also update `assets/data/fiat_currencies.json` and include a short validation note in `specs/master/data/`.

## License

- This repository is licensed under MIT (see `LICENSE`).

## Contact and Acknowledgements

- Maintainer: project team (open a GitHub issue or PR for questions).
- Data sources: thanks to the `@fawazahmed0/exchange-api` project and the `@fawazahmed0/currency-api` CDN.

---

**Note:** Keep `pubspec.yaml` and `assets/` synchronized when adding branding, flag, or currency-specific icon assets.
