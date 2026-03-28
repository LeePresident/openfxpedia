# Research Notes: Multi-Language App Support

## Decision 1: Use Flutter generated localization with ARB files

- Decision: Use Flutter's built-in localization generation flow with ARB resources for English and Chinese.
- Rationale: The repo already depends on `flutter_localizations` and `intl`, so generated localization keeps string management consistent with the framework and avoids a custom translation system.
- Alternatives considered: Manual string maps in code; a third-party localization package. Both were rejected because they add maintenance overhead and diverge from standard Flutter localization practices.

## Decision 2: Persist the selected locale in the existing app preference store

- Decision: Store the chosen language code in the existing Hive-backed preference box used by `CacheService`.
- Rationale: The app already persists theme and favorites through the same preference storage, so locale persistence fits the current architecture and avoids introducing a second persistence layer.
- Alternatives considered: Platform-specific shared preferences or file-based settings. These were rejected because the app already has a working preference store and the new setting is small.

## Decision 3: Apply locale at the `MaterialApp` boundary

- Decision: Pass the selected locale into `MaterialApp` and let the localization delegates render the active language.
- Rationale: This is the simplest way to keep the visible UI consistent while avoiding route resets or manual rebuild logic on each screen.
- Alternatives considered: Per-screen locale handling or custom inherited widgets. These were rejected because they increase complexity and risk inconsistent language behavior across screens.

## Decision 4: Keep launch scope limited to English, Traditional Chinese, and Simplified Chinese

- Decision: Treat English, Traditional Chinese, and Simplified Chinese as the launch languages while keeping the localization structure ready for more languages later.
- Rationale: This matches the updated requirement and allows the app to present Chinese in the script that best fits the user's preference while preserving the ability to add more locales later.
- Alternatives considered: Collapsing Chinese into a single locale. Rejected because the user explicitly requested support for both Traditional and Simplified Chinese.
