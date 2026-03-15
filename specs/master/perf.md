# Performance Benchmark Plan

## Objective
Validate conversion flow latency at p95 <= 2s for 100 representative samples.

## Scope
- Conversion flow benchmark focuses on conversion computation path and service orchestration overhead.
- Network is mocked/simulated in benchmark harness to isolate app-side latency.

## Measurement procedure
1. Run benchmark harness:
   - `dart run tool/conversion_benchmark.dart --samples 100 --threshold-ms 2000`
2. Harness records per-sample elapsed time in milliseconds.
3. Harness computes p95 and max latency.
4. CI fails when p95 exceeds threshold (`--threshold-ms`).

## Device classes (target)
- `android-mid`: representative mid-tier Android device/emulator.
- `windows-desktop`: typical developer desktop.

## CI definition
A dedicated CI job `benchmark_conversion` runs after analyze/test and executes:
- `dart run tool/conversion_benchmark.dart --samples 100 --threshold-ms 2000`

## Artifacts
- Benchmark summary is printed to logs.
- Future enhancement: persist raw samples as CI artifacts for regression trending.
