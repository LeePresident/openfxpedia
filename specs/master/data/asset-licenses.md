# Asset License Audit

- `assets/data/world-map-50m.json` — Natural Earth 1:50m Admin 0 Map
  Subunits, public domain: https://www.naturalearthdata.com/about/terms-of-use/.
  Derived from
  https://github.com/nvkelso/natural-earth-vector/blob/master/geojson/ne_50m_admin_0_map_subunits.geojson;
  retains geometry, name, and ISO_A2_EH identifiers only. Missing small
  territories are supplemented from the 1:10m map subunits at
  https://github.com/nvkelso/natural-earth-vector/blob/master/geojson/ne_10m_admin_0_map_subunits.geojson.
  Ascension Island and the U.S. Minor Outlying Islands use the catalog's
  respective AC and UM identifiers in place of their parent identifiers.

This document should list each asset and its license. Example format:

- assets/icons/usd.svg — CC0
- assets/icons/eur.svg — CC-BY-4.0

Automated audit: consider adding a script to scan `assets/` and produce this manifest.
