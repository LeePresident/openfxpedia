 # OpenFXpedia — Currency Converter & Encyclopedia

Overview

OpenFXpedia is a lightweight Flutter application combining a currency converter with a searchable currency encyclopedia (images, symbols, regions, descriptions). The app targets Windows (desktop) and Android.

Quick links

- Spec & tasks: `specs/master`

Features

- Fast currency conversion using live exchange rates (with local cache and offline support).
- Encyclopedia entries for fiat currencies: names, symbols, regions, descriptions and images.
- Light / Dark / System theme selection persisted in app settings.
- Favorites, quick-swap, and From/To chooser dialogs for fast workflows.

Prerequisites

- Flutter SDK (stable channel)
- Windows: enable desktop support (`flutter config --enable-windows-desktop`)
- Android: Android SDK + emulator or device
- Recommended: run `flutter doctor` to verify environment

Quickstart (Windows)

1. From repository root:

```powershell
flutter pub get
flutter run -d windows
```

Quickstart (Android emulator / device)

```powershell
flutter pub get
flutter run
```

Release builds

```powershell
# Windows
./scripts/build_windows.ps1

# EXE output (release)
# build/windows/x64/runner/Release/openfxpedia_<version>.exe

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

# EXE output (release)
# build/windows/x64/runner/Release/openfxpedia_<version>.exe

# Android (macOS/Linux/Git Bash)
bash ./scripts/build_android.sh
bash ./scripts/build_android.sh debug

# APK output (release)
# build/app/outputs/flutter-apk/openfxpedia_<version>.apk
# SHA1 output (release)
# build/app/outputs/flutter-apk/openfxpedia_<version>.apk.sha1
```

Performance benchmark

```powershell
dart run tool/conversion_benchmark.dart --samples 100 --threshold-ms 2000
```

APIs and Data Sources

- Exchange rates: https://github.com/fawazahmed0/exchange-api
- Currency list (ISO 4217): https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json

The app fetches live exchange rates from the exchange-api and uses the CDN JSON as the canonical source for currency metadata. The repository also maintains a curated whitelist asset at `assets/data/fiat_currencies.json` that ships with richer metadata used by the encyclopedia.

Assets

- Store app icons and currency images under `assets/` (for example `assets/icons/` and `assets/images/`).
- Ensure `pubspec.yaml` includes the assets entries before running the app.

Testing

- Run unit/widget tests with:

```powershell
flutter test
```

VS Code

- This repo includes `.vscode` launch and task configs to help run and debug the app on Windows and Android.
- If you use VS Code, open the workspace root and use the Run view to launch the app.

Troubleshooting

- If desktop build fails: verify desktop support and Visual Studio (with C++ workload) are installed for Windows.
- If Flutter cannot find devices: run `flutter doctor -v` and ensure Android SDK/emulator or Windows desktop is configured.
- For dependency issues: run `flutter pub get` and resolve pub errors.

Contributing

- Open a branch for your work and submit a PR. For feature design and tasks see `specs/master`.
- When adding or updating currency metadata, also update `assets/data/fiat_currencies.json` and include a short validation note in `specs/master/data/`.

License

- This repository is licensed under MIT (see `LICENSE`).

Contact / Acknowledgements

- Maintainer: project team (open a GitHub issue or PR for questions).
- Data sources: thanks to the `exchange-api` project and the `@fawazahmed0/currency-api` CDN.

---
Notes: keep `pubspec.yaml` and `assets/` synchronized when adding icons or images.
