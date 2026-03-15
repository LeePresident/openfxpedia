# Deprecated Currency Handling Policy

## Rule
The application supports non-deprecated ISO 4217 currencies only.

## Source of truth
- Currency code list: `https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json`
- Project whitelist metadata: `assets/data/fiat_currencies.json`

## Exclusion behavior
- Codes not present in the maintained fiat whitelist are excluded from UI and selection.
- If a previously supported code becomes deprecated/withdrawn, remove it from whitelist metadata.

## Flagging behavior
- If deprecated codes are detected in legacy cache entries, they are ignored for new selections.
- Historical favorites containing deprecated codes should remain non-breaking and be removable by user.

## Update cadence
- Reconcile whitelist monthly.
- Reconcile additionally before release.

## Reconciliation steps
1. Pull latest currency source data.
2. Compare with `assets/data/fiat_currencies.json`.
3. Remove deprecated/withdrawn codes.
4. Run tests and verify catalog load behavior.
5. Document changes in PR notes.
