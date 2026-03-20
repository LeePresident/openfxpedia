#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MODE="${1:-release}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter not found in PATH. Install Flutter and ensure 'flutter' is available."
  exit 1
fi

case "$MODE" in
  release|debug)
    ;;
  *)
    echo "Usage: bash ./scripts/build_windows.sh [release|debug]"
    exit 2
    ;;
esac

host="$(uname -s 2>/dev/null || echo unknown)"
if [[ "${OS:-}" != "Windows_NT" && "$host" != MINGW* && "$host" != MSYS* && "$host" != CYGWIN* ]]; then
  echo "Windows build requires a Windows host with desktop toolchain."
  exit 6
fi

cd "$REPO_ROOT"

version_raw="$(grep '^version:' pubspec.yaml | head -n1 | awk '{print $2}')"
if [ -z "$version_raw" ]; then
  echo "Unable to read version from pubspec.yaml"
  exit 3
fi
app_version="${version_raw%%+*}"

echo "==> Flutter pub get"
flutter pub get

echo "==> Enable Windows desktop support"
flutter config --enable-windows-desktop

if [ "$MODE" = "release" ]; then
  echo "==> Building Windows release"
  flutter build windows --release
  build_folder="Release"
else
  echo "==> Building Windows debug"
  flutter build windows --debug
  build_folder="Debug"
fi

source_exe="build/windows/x64/runner/${build_folder}/openfxpedia.exe"
if [ ! -f "$source_exe" ]; then
  echo "Expected EXE not found: $source_exe"
  exit 4
fi

if [ "$MODE" = "release" ]; then
  target_name="openfxpedia_${app_version}.exe"
else
  target_name="openfxpedia_${app_version}_debug.exe"
fi

target_exe="build/windows/x64/runner/${build_folder}/${target_name}"
mv -f "$source_exe" "$target_exe"

echo "Windows build completed (${MODE})."
echo "EXE: $target_exe"
