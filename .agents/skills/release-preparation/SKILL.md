---
name: release-preparation
description: 'Prepare and verify an OpenFXpedia release. Use when bumping versions, writing changelog or release notes, updating bundled changelog entries, building Windows installers or portable executables, building Android APKs, or checking release artifact names and hashes.'
argument-hint: '<version> [windows|android|all]'
---

# Release Preparation

Prepare release metadata and artifacts as one consistent change. Do not publish, tag, commit, or push unless explicitly requested.

## Metadata Procedure

1. Confirm the intended semantic version and review changes since the previous release.
2. Update the `version:` field in `pubspec.yaml`.
3. Add the matching dated section to `CHANGELOG.md`.
4. Add `releases/v<version>_release_notes.md`, following the latest release-note structure.
5. Update `assets/data/changelog_entries.json` so in-app release information matches the Markdown release notes.
6. Review fallback version strings and the original executable filename in `windows/runner/Runner.rc`.
7. Search for the old current version and inspect each remaining occurrence before deciding whether it should change. Do not edit generated or machine-local values such as `android/local.properties`.
8. Verify that the update-check flow expects the same GitHub tag and asset names produced by the build scripts.
9. Confirm changelog versions are unique, newest first, and consistent between Markdown and bundled JSON.

## Validation Procedure

Run the normal quality gate before packaging:

```powershell
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Build only requested platforms:

```powershell
# Windows release: portable EXE and NSIS installer
./scripts/build_windows.ps1

# Android release: versioned APK and SHA-1 file
./scripts/build_android.ps1
```

Use `-Mode debug` only for non-release smoke builds. The Windows release script requires `makensis` from NSIS.

## Artifact Checks

- Windows portable: `build/windows/portable/openfxpedia_<version>.exe`
- Windows installer: `build/windows/installer/openfxpedia_<version>_setup.exe`
- Android APK: `build/app/outputs/flutter-apk/openfxpedia_<version>.apk`
- Android hash: the adjacent `.apk.sha1` file must name the versioned APK.

Verify the files exist, inspect their versioned names, and report their paths and hashes. Smoke-test the in-app update link when update-service behavior or artifact naming changed. Do not add generated `build/` artifacts to source control unless the user explicitly requests it.
