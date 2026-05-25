# Changelog

All notable changes to this project are documented in this file.

## [1.0.2] - 2026-05-25

- Use Frankfurter as the primary exchange-rate API with a reliable fallback.
- Refactored rate source handling and updated `RateInfoWidget` usage.
- Enhanced localization: cleaned up i18n keys and added localized error messages.
- Added splash screen support with dark mode and localized assets.
- Removed an obsolete Flutter CI workflow configuration and updated the README.


## [1.0.1] - 2026-04-05

- Bumped package version to `1.0.1`.
- Implemented app-wide i18n for the currency encyclopedia and related UI.

## [1.0.0] - 2026-03-15

- Bumped package version to `1.0.0`.
- Initial currency picker now uses a searchable selector (tap From/To to open the search dialog).
- Converter screen and encyclopedia icon rendering updated for edge-to-edge SVG display.
- Added bundled, copyright-safe SVG icons and a generated icon asset map.
- Added integration and unit tests (encyclopedia flow, favorites). All tests pass locally.
- Added microbenchmark harness and CI integration for p95 latency checks.
- Updated VS Code `/.vscode/launch.json` to specify `program` and `deviceId` for consistent debugging.
- Performed repo-wide comment cleanup and repaired string literal issues introduced during that pass.

### Notes

- All changes validated locally with `flutter analyze` and `flutter test`.
- The comment-cleanup edits are present in the working tree and were not auto-committed unless reviewed.
