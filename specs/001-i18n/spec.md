# Feature Specification: Multi-Language App Support

**Feature Branch**: `001-i18n`  
**Created**: 2026-03-26  
**Status**: Draft  
**Input**: User description: "I want to add i18n so the app can be switched in multiple languages"

## Clarifications

### Session 2026-03-26
- Q: Should translations cover only the app UI, or also currency encyclopedia content and other in-app text? → A: UI + all in-app text
- Q: Which languages should be selectable at launch? → A: English, Traditional Chinese, and Simplified Chinese

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Switch Language Manually (Priority: P1)
A user wants to change the app language from within settings and immediately continue using the app in that language.

**Why this priority**: This is the core value of the feature. Without a visible language switch, the app is not meaningfully multi-language for the user.

**Independent Test**: Open settings, choose a supported language, and verify that visible text updates without losing the current screen or user inputs.

**Acceptance Scenarios**:

1. **Given** the app is open, **When** the user selects a supported language in settings, **Then** the visible app text updates to that language.
2. **Given** the user changes language while using the converter or encyclopedia, **When** the selection is confirmed, **Then** the current screen remains usable and shows the new language.

---

### User Story 2 - Use a Sensible Default (Priority: P2)
A user wants the app to open in a language that matches their device preferences when possible.

**Why this priority**: This reduces setup friction and gives users a usable experience on first launch.

**Independent Test**: Install or reset the app, open it on a device with a supported system language, and verify that the app starts in that language.

**Acceptance Scenarios**:

1. **Given** the app is opened for the first time, **When** the device language is supported, **Then** the app uses that language automatically.
2. **Given** the device language is not supported, **When** the app is opened for the first time, **Then** the app uses the default language.

---

### User Story 3 - Preserve Readability When Coverage Is Incomplete (Priority: P3)
A user wants the app to remain understandable even if a translation is not available for every string.

**Why this priority**: It protects the user experience while translations are being expanded over time.

**Independent Test**: Switch to a supported language that has partial translation coverage and verify that missing text falls back to the default language without broken labels.

**Acceptance Scenarios**:

1. **Given** a supported language does not have a translation for every string, **When** the user uses the app, **Then** the app shows the untranslated text in the default language rather than a placeholder or blank label.
2. **Given** the app language is changed, **When** the user revisits key screens, **Then** the app remains readable and consistent.

### Edge Cases

- What happens when the selected language is no longer available? The app should fall back to the default language and keep the app usable.
- What happens when a translation is missing for a dialog, error, or empty state? The app should show the default language for that string only.
- What happens when language is changed during an active conversion or browsing session? The current screen state should remain intact.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST let users choose their preferred language from a visible settings control.
- **FR-002**: The app MUST apply the selected language across all user-facing text, including navigation labels, screen titles, buttons, prompts, empty states, error messages, encyclopedia content, and other in-app copy.
- **FR-003**: The app MUST remember the user's language choice across app restarts.
- **FR-004**: On first launch, the app MUST use the device language when it is supported; otherwise it MUST use the default language.
- **FR-005**: If a selected language does not include every string, the app MUST fall back to the default language for missing text without showing broken, blank, or placeholder text.
- **FR-006**: The app MUST support English, Traditional Chinese, and Simplified Chinese as selectable languages at launch.
- **FR-007**: Changing the language MUST NOT clear the user's current converter inputs, selected currencies, favorites, or current browsing position.
- **FR-008**: The language-switching flow MUST be independently testable from the rest of the app.
- **FR-009**: The language system MUST allow additional supported languages to be added later without changing the existing user-facing language-switch flow.

### Key Entities *(include if feature involves data)*

- **Supported Language**: A language the app can present to users, identified by a language code and display name.
- **Language Preference**: The user's chosen language setting, including whether it was selected manually or inherited from the device.
- **Localized Content**: The user-facing text shown in a given language, including fallback behavior when a translation is missing.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can switch the app language from settings and see the interface update within one interaction flow, without leaving the current screen.
- **SC-002**: On relaunch, the app opens in the previously selected language for 100% of validation runs.
- **SC-003**: In supported languages, the main user journeys for converter, encyclopedia, and settings show translated text for all primary controls and screen titles during acceptance testing.
- **SC-004**: Users can complete the language-change task in three taps or fewer from the settings screen.
- **SC-005**: Missing translations never prevent a user from completing a primary task or cause unreadable text in the app.

## Assumptions

- English is the default fallback language.
- Chinese remains a supported launch language alongside English, with separate Traditional and Simplified Chinese options.
- Additional languages may be added later without changing the core switching flow.
