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
    echo "Usage: bash ./scripts/build_linux.sh [release|debug]"
    exit 2
    ;;
esac

if [ "$(uname -s)" != "Linux" ]; then
  echo "Linux build requires a Linux host with the desktop toolchain."
  exit 6
fi

if [ "$(uname -m)" != "x86_64" ]; then
  echo "Linux build currently supports x86_64 hosts only."
  exit 7
fi

if [ "$MODE" = "release" ] && ! command -v tar >/dev/null 2>&1; then
  echo "tar not found in PATH; it is required to package the release bundle."
  exit 8
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

echo "==> Enable Linux desktop support"
flutter config --enable-linux-desktop

echo "==> Building Linux ${MODE}"
flutter build linux "--$MODE"

if [ "$MODE" = "release" ]; then
  source_bundle="build/linux/x64/release/bundle"
  if [ ! -d "$source_bundle" ]; then
    echo "Expected Linux bundle not found: $source_bundle"
    exit 4
  fi

  output_dir="build/linux"
  mkdir -p "$output_dir"
  archive_path="$output_dir/openfxpedia_${app_version}_linux_x64.tar.gz"
  stage_root="$(mktemp -d "$output_dir/openfxpedia-${app_version}-XXXXXX")"
  trap 'rm -rf "$stage_root"' EXIT

  package_name="openfxpedia_${app_version}_linux_x64"
  package_dir="$stage_root/$package_name"
  mkdir -p "$package_dir"
  cp -a "$source_bundle/." "$package_dir/"
  tar -czf "$archive_path" -C "$stage_root" "$package_name"

  echo "Linux release build completed."
  echo "Archive: $archive_path"
else
  echo "Linux debug build completed."
  echo "Bundle: build/linux/x64/debug/bundle"
fi
