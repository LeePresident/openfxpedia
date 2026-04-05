# Performance Measurement Guidance

Purpose: document how to measure UI update latency for locale switching and what constitutes an actionable measurement.

Measurement guidance:
- Device class: prefer a small set of representative devices (e.g., `android-mid` emulator with x86 image, and a Windows desktop dev machine) for reproducible results.
- Warm vs cold: measure warm app state (already running, view open) for the user-visible update latency; measure cold startup separately if required.
- Measurement harness: use a widget/integration test that captures timestamps before and after `AppState.setLocale(...)` and measures when the key widget tree element reaches the expected text. Use platform-specific instrumentation for more accurate wall-clock timing when needed.

Goal: aim for p95 ~300ms for visible UI update on representative devices. Treat this as a goal; only enforce after establishing a stable harness and representative device pool.

Deliverable: `specs/001-i18n/perf.md` (this file) and at least one perf harness in `tool/` or `test_driver/` if the team decides to formalize enforcement.
