#!/usr/bin/env bash
set -euo pipefail

echo "==> flutter pub get"
flutter pub get

echo "==> Building Android APK (release)"
flutter build apk --release

echo "Android build completed."
