# Content Localization: Encyclopedia

Purpose: document the approach to localizing encyclopedia content so FR-002 (apply selected language across all user-facing text including encyclopedia content) is satisfied.

Options considered:
- Per-locale content files under `assets/encyclopedia/{en,zh_Hans,zh_Hant}/...` (static, easiest to ship with app).
- Server-side translations with on-demand fetch and local caching (dynamic, supports many locales later).

Recommended approach (MVP):
- Create per-locale content assets in `assets/encyclopedia/` for the three launch locales. Each content file is keyed by encyclopedia id and contains localized fields (title, body, shortDescription).
- Provide a migration script to export existing encyclopedia entries into the `en` assets and to assist translators for other locales.

Acceptance criteria:
- Encyclopedia content displays the locale-specific asset when available.
- When a locale asset is missing for an item, the app falls back to the `en` asset and emits a structured missing-content log event.
- Unit/widget tests exist to verify both localized and fallback behavior.

Deliverables:
- `assets/encyclopedia/{en,zh_Hans,zh_Hant}/...` or a placeholder set for zh locales
- `scripts/export_encyclopedia_for_translation.dart` (or simple JSON extraction script)
- `test/widget/encyclopedia_locale_test.dart`
