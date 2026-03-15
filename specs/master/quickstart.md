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
- See `pubspec.yaml` for dependencies.
