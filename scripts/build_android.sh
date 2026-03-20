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
		echo "Usage: bash ./scripts/build_android.sh [release|debug]"
		exit 2
		;;
esac

cd "$REPO_ROOT"

version_raw="$(grep '^version:' pubspec.yaml | head -n1 | awk '{print $2}')"
if [ -z "$version_raw" ]; then
	echo "Unable to read version from pubspec.yaml"
	exit 3
fi
app_version="${version_raw%%+*}"

echo "==> flutter pub get"
flutter pub get

if [ "$MODE" = "release" ]; then
	echo "==> Building Android APK (release)"
	flutter build apk --release
else
	echo "==> Building Android APK (debug)"
	flutter build apk --debug
fi

source_apk="build/app/outputs/flutter-apk/app-${MODE}.apk"
if [ ! -f "$source_apk" ]; then
	echo "Expected APK not found: $source_apk"
	exit 4
fi

source_sha1="${source_apk}.sha1"

if [ "$MODE" = "release" ]; then
	target_name="openfxpedia_${app_version}.apk"
else
	target_name="openfxpedia_${app_version}_debug.apk"
fi

target_apk="build/app/outputs/flutter-apk/${target_name}"
mv -f "$source_apk" "$target_apk"

if [ -f "$source_sha1" ]; then
	rm -f "$source_sha1"
fi

target_sha1="${target_apk}.sha1"
if command -v sha1sum >/dev/null 2>&1; then
	hash="$(sha1sum "$target_apk" | awk '{print $1}')"
elif command -v shasum >/dev/null 2>&1; then
	hash="$(shasum -a 1 "$target_apk" | awk '{print $1}')"
else
	echo "No SHA1 tool found (need sha1sum or shasum)."
	exit 5
fi

printf '%s  %s\n' "$hash" "$target_name" > "$target_sha1"

echo "Android build completed (${MODE})."
echo "APK: $target_apk"
echo "SHA1: $target_sha1"
