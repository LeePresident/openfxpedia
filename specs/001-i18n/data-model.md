# Data Model: Multi-Language App Support

## Entities

### SupportedLanguage

- `code`: Locale code such as `en` or `zh`.
- `displayName`: User-facing label shown in settings.
- `isDefault`: Whether this language is the fallback language.
- `isLaunchSupported`: Whether it is selectable in the current release.

### LanguagePreference

- `languageCode`: The selected locale code.
- `source`: How the locale was chosen, either from the device or manually by the user.
- `updatedAt`: When the preference was last changed.

### LocalizedContent

- `key`: Identifier for a translatable string.
- `languageCode`: Locale for the rendered string.
- `value`: The translated text.
- `fallbackLanguageCode`: Default locale to use when the string is missing.

## Relationships

- `LanguagePreference` references one `SupportedLanguage` by `languageCode`.
- `LocalizedContent` is resolved against the set of `SupportedLanguage` values at runtime.
- `SupportedLanguage` drives the choices shown in settings and the values accepted by the app's locale switcher.

## Validation Rules

- The stored language code must match one of the supported launch locales unless the app is falling back to the default language.
- Missing translations must resolve to the default language for that string instead of rendering blank text.
- Changing `LanguagePreference` must not modify unrelated persisted state such as theme, favorites, or cached rates.

## State Transitions

- `device-default` -> `manual-selection` when the user chooses a language in settings.
- `manual-selection` -> `device-default` only when the preference is cleared or invalidated and the app falls back to the device language.
- `any` -> `fallback-default` when a translation key is missing for the active locale.
