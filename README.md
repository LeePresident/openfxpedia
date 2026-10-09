 # OpenFXpedia — Currency Converter & Encyclopedia

[English](README.md) | [简体中文](README.zh-Hans.md) | [繁體中文](README.zh-Hant.md)

## Overview

OpenFXpedia is a lightweight Flutter application combining a currency converter with a searchable currency encyclopedia (flags, symbols, regions, and descriptions). The app targets Windows (desktop) and Android.

Current release: `1.0.5`

## Quick Links

- Project documentation and design history: `specs/master`

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
- Date-based conversion with historical rates, requested and actual rate dates, and a quick return to latest rates.
- Select the exchange-rate API source from Settings, with automatic primary/fallback behavior.
- Encyclopedia entries for fiat currencies: names, symbols, regions, descriptions, and usage-region flags.
- Major/minor units and coin/banknote denominations, with shortcuts for converting a selected denomination.
- Search currencies by name, code, or ISO 4217 numeric code, with clear-search support.
- Light / Dark / System theme selection persisted in app settings.
- English, Simplified Chinese, and Traditional Chinese language selection in Settings.
- Favorites, quick-swap, and From/To chooser dialogs for fast workflows.
- In-app update checks open the device-specific GitHub release asset: `openfxpedia_<version>_setup.exe` on Windows and `openfxpedia_<version>.apk` on Android.

## Prerequisites

- Flutter SDK (stable channel)
- Windows: Visual Studio Build Tools with the Desktop development with C++ workload; enable desktop support with `flutter config --enable-windows-desktop`
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
# Portable bundle for distribution
# build/windows/openfxpedia_<version>_portable.zip

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

### Historical Conversion

Open **Rate history** below the conversion result for a 1-week, 1-month, or 3-month chart ending on the selected conversion date (today in latest mode). Each range uses up to eight evenly spaced dated samples, not a complete daily series. Hover or tap a point for its actual quote date, rate per unit of the base currency, provider, and cache status. Missing quotes leave gaps; repeated quote dates are not plotted twice in a continuous segment. The chart refresh button rechecks its samples without changing the conversion result. Existing source selection and encrypted historical caching also apply to charts.

Choose **Conversion date** in the converter to select a date from 1948 through today. Availability depends on the currency pair and provider; not every date in the picker has coverage. **Use latest rates** restores the default mode without changing the amount or currencies.

Historical requests use Frankfurter's dated pair endpoint or Exchange API's dated archives. Automatic fallback retains the selected date, while a manually selected source never switches providers. Quotes dated after the requested day are rejected; an earlier quote returned by the provider is shown with both the requested date and actual rate date. Historical failures never substitute today's rates.

Historical snapshots are stored in the existing encrypted local cache, separately by currency pair, requested date, and source selection. Past-date snapshots can be reused offline. **Refresh rates** rechecks the selected date and uses its compatible cached snapshot if the request fails. **Clear local data** also removes historical snapshots. Rates remain reference estimates, not guaranteed bank quotes or official accounting rates.

## Privacy

OpenFXpedia does not require an account and does not collect names, email addresses, payment information, contacts, location, camera, microphone, or advertising identifiers. The app does not include analytics, advertising, crash-reporting, or user-tracking SDKs.

The app makes HTTPS requests to the configured exchange-rate and currency-catalog providers listed above. These requests include the selected currency codes needed to retrieve rates and catalog data. The app also contacts the OpenFXpedia GitHub repository when the user checks for updates. The external providers and GitHub may receive normal connection metadata such as an IP address according to their own privacy policies.

Rates and currency catalog data are cached locally for offline use. Favorites and app preferences are also stored locally. These Hive data boxes are encrypted with a randomly generated key stored in the app-support directory. Encryption protects the app's stored data from casual inspection, but the key is stored locally rather than in a hardware-backed vault, so it does not protect data on a device that is already compromised or unlocked by an attacker.

To delete locally stored rates, catalog data, favorites, and preferences, open **Settings** and choose **Clear local data**. Clearing local data retains the encryption key so any future cached data remains encrypted. Uninstalling the app removes its application data according to the operating system's normal uninstall behavior.

The Android app requests only the `INTERNET` permission. Network communication uses HTTPS, and update artifacts are downloaded only after their GitHub release URL and SHA-256 digest have been checked against the GitHub release metadata. This detects wrong or corrupted downloads; it is not an independent publisher signature, so a compromised release source remains outside the app's trust boundary. No personal data is intentionally included in exchange-rate requests or update checks.

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
flutter test test/widget/converter_history_test.dart
```

## Localization Notes

- Update `lib/l10n/app_en.arb` first when adding a new string.
- Keep `lib/l10n/app_zh_Hans.arb` and `lib/l10n/app_zh_Hant.arb` aligned with the English key set.
- `lib/l10n/app_zh.arb` is the neutral Chinese fallback source for the `zh` locale family.
- `OpenFXpedia` is a product name and remains unchanged in every locale.
- Regenerate the checked-in localization output after ARB changes with `flutter gen-l10n`, then run `dart format lib/l10n`.

The startup screen is rendered by Flutter so its loading status and startup errors can use the selected locale. Windows keeps this Flutter-rendered screen visible while the app initializes; Android uses the native splash until Flutter is ready and then removes it.

## VS Code

- Shared VS Code configuration examples are in `.vscode.example/`; copy that folder to `.vscode/` to use them. The local `.vscode/` folder is gitignored so personal settings are not committed.
- Open the workspace root, then use the Run view to launch the app on Windows or Android.

## Troubleshooting

- If desktop build fails: verify desktop support and Visual Studio (with C++ workload) are installed for Windows.
- If installer build fails: verify NSIS is installed and `makensis` is available in PATH.
- If Flutter cannot find devices: run `flutter doctor -v` and ensure Android SDK/emulator or Windows desktop is configured.
- For dependency issues: run `flutter pub get` and resolve pub errors.

## Contributing

- Open a branch for your work and submit a PR. For project design context and implementation history, see `specs/master`; it contains documentation, not an active task workflow.
- When adding or updating currency metadata, also update `assets/data/fiat_currencies.json` and include a short validation note in `specs/master/data/`.

## License

- This repository is licensed under MIT (see `LICENSE`).

## Contact and Acknowledgements

- Maintainer: project team (open a GitHub issue or PR for questions).
- Data sources: thanks to the `@fawazahmed0/exchange-api` project and the `@fawazahmed0/currency-api` CDN.

---

**Note:** Keep `pubspec.yaml` and `assets/` synchronized when adding branding, flag, or currency-specific icon assets.
