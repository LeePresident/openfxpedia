# Feature Specification: Frankfurter Primary Exchange Source

**Feature Branch**: `001-frankfurter-fallback-api`  
**Created**: 2026-05-07  
**Status**: Draft  
**Input**: User description: "I want to utilize https://github.com/lineofflight/frankfurter as the primary API and the current API will become fallback option."

## Clarifications

### Session 2026-05-07
- Q: When should the app switch from the primary source to the fallback source? → A: When the primary source is unreachable, times out, returns invalid data, or does not provide the requested rate.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Prefer the New Primary Source (Priority: P1)

A user wants currency conversion results to come from the new primary exchange source whenever it is available.

**Why this priority**: This is the main purpose of the change. It shifts the app to the preferred data source without changing the user workflow.

**Independent Test**: Perform a conversion while the primary source is available and verify the result is returned normally.

**Acceptance Scenarios**:

1. **Given** the primary exchange source is available, **When** the user requests a currency conversion, **Then** the app returns a conversion result using the primary source.
2. **Given** the primary exchange source returns valid data for the requested pair, **When** the app refreshes rates, **Then** the app uses that data for the conversion flow.

---

### User Story 2 - Keep Conversions Working Through Fallback (Priority: P1)

A user wants conversions to continue working when the primary source is unavailable.

**Why this priority**: Continuity is critical. A fallback path prevents the app from losing core functionality when the preferred source has an outage or missing data.

**Independent Test**: Simulate a primary-source failure and verify the app still returns a conversion result from the fallback source.

**Acceptance Scenarios**:

1. **Given** the primary source cannot be reached, **When** the user requests a conversion and the fallback source is available, **Then** the app returns a conversion result from the fallback source.
2. **Given** the primary source does not provide the requested rate, **When** the fallback source provides that rate, **Then** the app uses the fallback result instead of failing the conversion.

---

### User Story 3 - Make Source Choice Visible (Priority: P2)

A user wants to know which source produced the displayed exchange rate.

**Why this priority**: Source visibility builds trust and helps explain why a rate may differ from a previous conversion.

**Independent Test**: Complete conversions under primary-source and fallback-source conditions and confirm the source shown to the user matches the data used.

**Acceptance Scenarios**:

1. **Given** a conversion result is shown, **When** the user reviews the rate details, **Then** the app identifies whether the primary or fallback source supplied the rate.
2. **Given** a fallback occurred, **When** the result is displayed, **Then** the app clearly indicates that the fallback source was used.

### Edge Cases

- If the primary source is reachable but returns incomplete, invalid, or unusable data, the app should attempt the fallback source before showing an error.
- If both sources are unavailable, the app should preserve the user’s entered values and show a clear error message with guidance to retry later.
- If the primary and fallback sources return different rates, the app should use the primary source first and only switch to the fallback when needed.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST attempt to retrieve exchange rates from the primary exchange source before using any fallback source.
- **FR-002**: If the primary exchange source is unavailable, times out, returns invalid data, is incomplete, or does not provide the requested rate, the app MUST attempt the fallback source.
- **FR-003**: The app MUST return a conversion result whenever either the primary or fallback source can provide the requested rate.
- **FR-004**: The app MUST clearly indicate which source supplied the displayed exchange rate.
- **FR-005**: If the app uses the fallback source, the app MUST make that fallback use visible to the user.
- **FR-006**: If neither source can provide a usable rate, the app MUST show a user-friendly error and preserve the user’s current inputs.
- **FR-007**: The app MUST retain enough rate metadata to distinguish the source and last successful refresh time for the displayed conversion.
- **FR-008**: The primary/fallback source behavior MUST remain independently testable from the rest of the conversion flow.

### Key Entities *(include if feature involves data)*

- **Primary Exchange Source**: The preferred exchange-rate provider used first for rate lookup.
- **Fallback Exchange Source**: The alternate exchange-rate provider used when the primary source fails or cannot satisfy the request.
- **Exchange Rate Result**: A displayed conversion outcome containing the source used, the requested currencies, the converted amount, and the last refresh time.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In automated validation runs of at least 100 conversion requests where the primary source is available and healthy, at least 95% of conversion requests use the primary source.
- **SC-002**: In validation runs where the primary source fails but the fallback source is available, at least 95% of conversion requests still return a result.
- **SC-003**: Users can identify the source of a displayed rate in 100% of successful conversion results.
- **SC-004**: When both sources are unavailable, 100% of affected users see a clear error while their entered values remain intact.

## Assumptions

- The existing exchange-rate provider remains available as the fallback source.
- The app’s conversion screens and stored user inputs should continue to behave as they do today except for the source preference change.
- A missing, incomplete, invalid, or timed-out response from the primary source counts as a fallback trigger.
