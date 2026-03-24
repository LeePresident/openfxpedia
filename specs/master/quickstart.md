# Quickstart — openfxpedia

Run the app for development (Windows):

```powershell
flutter pub get
flutter run -d windows
```

Run on Android (device/emulator):

```bash
flutter pub get
flutter run -d android
```

Release builds:

```powershell
./scripts/build_windows.ps1
```

The PowerShell Windows release build produces a portable EXE under `build/windows/portable/` plus an NSIS installer under `build/windows/installer/`.
Install NSIS first so `makensis` is available on PATH.

In-app update checks open the matching GitHub release asset for the current device: `openfxpedia_<version>_setup.exe` on Windows or `openfxpedia_<version>.apk` on Android.

```bash
bash ./scripts/build_android.sh
```

Run tests:

```bash
flutter test
```

Run performance benchmark:

```bash
dart run tool/conversion_benchmark.dart --samples 100 --threshold-ms 2000
```

Notes:
- Ensure Flutter SDK is installed and `flutter` is on PATH.
- For Windows builds, Visual Studio with Desktop Development workload is required.
- For the NSIS installer, install NSIS so `makensis` is on PATH.
- See `pubspec.yaml` for dependencies.
