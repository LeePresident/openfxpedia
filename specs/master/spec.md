# Feature Specification: Currency Converter & Encyclopedia

**Feature Branch**: `master`  
**Created**: 2026-03-08  
**Status**: Draft  
**Input**: User description: "Build a Flutter app in Windows and Android to convert currencies based on my selection. Also include an encyclopedia for currencies with images. Use https://github.com/fawazahmed0/exchange-api for exchange rates."

## Clarifications

### Session 2026-03-09
- Q: Image sourcing strategy → A: C (Use generic icons for all currencies; no runtime image fetching)
 - Q: Supported currency set → A: A (Support all non-deprecated ISO 4217 currencies from the CDN JSON)
 - Q: Rate refresh policy → A: B (Refresh on app open + background refresh every 12 hours; manual refresh available)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Quick Conversion (Priority: P1)
A user wants to convert an amount from one currency to another quickly.

**Why this priority**: Core user value — the primary purpose of the app.

**Independent Test**: Open app, select source and target currencies, enter amount, observe converted result and timestamp.

**Acceptance Scenarios**:
1. **Given** the app is online and rates are available, **When** the user selects two currencies and an amount, **Then** the app shows the converted amount and the rate timestamp.
2. **Given** the app is offline but has cached rates, **When** the user performs a conversion, **Then** the app shows a conversion using the last-cached rates and clearly marks them as cached.

---

### User Story 2 - Currency Encyclopedia (Priority: P2)
A user wants to browse currency details and see a representative image for each currency.

**Why this priority**: Provides secondary value and discovery; supports learning about currencies.

**Independent Test**: Open encyclopedia, view a currency entry, verify image, name, ISO code, regions using the currency, and a short description are shown.

**Acceptance Scenarios**:
1. **Given** a supported currency, **When** the user opens its encyclopedia entry, **Then** the app shows an image (or placeholder), the currency name, ISO code, symbol, associated regions, and a short description.

---

### User Story 3 - Manage Favorites & Search (Priority: P3)
A user manages a shortlist of frequently used currencies.

**Why this priority**: Improves repeat-usage flow for frequent conversions.

**Independent Test**: Add/remove currencies to favorites, search for a currency by name or code, and use favorites as quick selections in the converter.

**Acceptance Scenarios**:
1. **Given** the user has favorites, **When** they open the converter, **Then** favorites appear as quick-select options.

---

### Edge Cases
- What happens when the exchange API is unreachable? App should show cached rates or an error with guidance.
- How to handle ambiguous or deprecated currency codes? App should show authoritative ISO code and note deprecated status if applicable.
- Very large or very small amounts should be displayed with appropriate formatting and rounding rules.

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: App MUST allow users to convert an entered amount from a selected source currency to a selected target currency using rates from the exchange API or cached rates when offline.
- **FR-002**: App MUST run on Windows (desktop) and Android (mobile) with responsive UI appropriate for each platform.
 - **FR-002**: App MUST run on Windows (desktop) and Android (mobile) with responsive UI appropriate for each platform.

#### FR-002 Acceptance Criteria (concrete)
- Viewport classes and layout expectations:
	- Mobile (width <= 480px): single-column layout; controls must be reachable with one hand, primary actions visible without scrolling.
	- Tablet (481px–1024px): adaptive two-column layout where lists and details can appear side-by-side.
	- Desktop (>1024px): multi-pane layout allowed (persistent sidebar or two-column); lists should show denser rows and allow keyboard navigation.
- Tests: Provide widget/layout tests that assert the main screens render the expected layout at the three breakpoint widths above (mobile/tablet/desktop). Provide at least one screenshot per breakpoint as an artifact for manual review.

#### Performance Measurement (concrete)
- Define device classes for measurement:
	- `android-mid`: Android emulator profile or device roughly equivalent to Pixel 4 / ARM Cortex-A53, 2GB RAM.
	- `windows-desktop`: Typical developer desktop — 4-core CPU, 8GB RAM.
- Measurement method: p95 latency over 100 representative conversion requests measured in an integration test harness (mocked network to isolate client latency). The success threshold: p95 <= 2s for `android-mid` and `windows-desktop` when running the conversion flow with in-memory parsing and UI binding.
	- Record and store raw latency samples as build artifacts for regression analysis.
- **FR-003**: App MUST display the rate timestamp and indicate whether a rate is live or cached.
-- **FR-004**: App MUST include an encyclopedia section where each supported currency has an entry containing: image (or placeholder), ISO code, name, symbol, associated regions/territories, and a short description.
- **FR-005**: Users MUST be able to search currencies by name, ISO code, or region and mark/unmark currencies as favorites.
- **FR-006**: App MUST cache the last-fetched rates and currency metadata for offline use and expose a user-visible cache age.
- **FR-007**: App MUST handle API failures gracefully and show an explanatory error message with retry option.
- **FR-008**: All functional requirements MUST be independently testable via the Acceptance Scenarios above.
*Marked unclear where choices materially affect scope:*

- **FR-009**: Image sourcing strategy: Use generic icons for all currencies bundled with the app (no runtime image fetching). Placeholders will be used when an icon is not available. This minimizes app size, reduces runtime failures, and avoids licensing complexity.
- **FR-010**: Supported currency set: The app will support all non-deprecated ISO 4217 currencies available from the public CDN at `https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json`. Deprecated or withdrawn codes reported by the CDN or ISO will be excluded; the catalog will be reconciled monthly and on deploy.
 - **FR-011**: Rate refresh policy: Refresh on app open, background refresh every 12 hours, and on explicit user request (manual refresh). The app will display the UTC timestamp for rates and clearly indicate when cached rates are used.
 - **FR-012**: Initial currency selection: On first run (or when no default is configured), the app MUST prompt the user to select the `From` and `To` currencies before allowing conversions. The user selection should populate the converter fields and be changeable later.
	- **UI Note**: Currency selection interfaces will include both a compact dropdown for quick picks and a searchable text field with filtered results to make selection convenient on all form factors.

### Key Entities
- **Currency**: { `iso_code`, `name`, `symbol`, `icon_asset`, `regions`, `description` }
- **ExchangeRate**: { `base_currency`, `target_currency`, `rate`, `timestamp`, `source` }
- **UserPreference**: { `favorites`: list of `iso_code`, `default_currency`, `cache_policy` }

## Success Criteria
- Users can complete a single currency conversion (select source, target, enter amount, view result) within 2 steps and the app displays the converted amount and rate timestamp.
- 95% of conversion requests return a displayed result within 2 seconds on a modern Android device and a Windows desktop with network connectivity.
- The encyclopedia displays image + metadata for at least 90% of the app’s supported currencies (or a clear placeholder when an image is unavailable).
- Offline mode: when offline, users can still convert using cached rates and are notified that rates are cached; at least 80% of recent conversions succeed using cached rates.

## Non-Functional Considerations (assumptions)
- The app will use the public exchange API at https://github.com/fawazahmed0/exchange-api as the primary source of rates.
- Images will be bundled with the app as a permissively-licensed icon set; runtime fetching is not required. Placeholders will be used when an icon is unavailable.
 - The app will support all non-deprecated ISO 4217 currencies as provided by the referenced CDN JSON; large datasets will be paginated or lazily loaded in the UI as needed.

## Testing Notes
- Unit tests for rate parsing and conversion math (including precision and rounding rules).
- Integration tests for API responses (mocked) and cache fallback behavior.
- Manual UX tests on Windows and Android for layout, selection flows, and encyclopedia navigation.

## Assumptions
- The user wants a polished cross-platform Flutter app (Windows + Android) and is willing to accept reasonable defaults for image sourcing, supported currency set, and refresh policy until clarified.
- No paid API keys are required for the exchange-api; it’s public and rate-limited per the API’s documentation.

## Next Steps
1. Answer the 3 clarification questions marked above (image source, supported currency set, refresh policy).  
2. On confirmation, produce a planning/tasks document and an initial UI mockup and data model.  

---

*Spec generated from user input: Build a Flutter app in Windows and Android to convert currencies based on my selection. Also include an encyclopedia for currencies with images. Use https://github.com/fawazahmed0/exchange-api.*

Tooling Note
The repository's `/speckit` tooling maps a feature branch name to the `specs/` folder (for example: branch `001-currency-converter` → `specs/001-currency-converter`). If you rename the specs folder or use a different name (for example `specs/master`), tooling that expects the original mapping may fail.

Remediation options:
- Keep the feature folder name and branch name in sync (recommended).
- Set the environment variable `SPECIFY_FEATURE` to the specs folder name in your shell or CI environment before running `/speckit.*` commands (e.g. `powershell: $env:SPECIFY_FEATURE='master'`).
- Create a filesystem junction from the expected folder name to the actual folder (the repo already contains a temporary junction to help automation).

Update `quickstart.md` or CI to document your chosen approach so automation remains robust.
