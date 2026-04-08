---
phase: 04-test-and-ci-expansion
plan: 03
status: completed-with-blocked-local-verification
commit: d370fcd
---

# Phase 4 Plan 03: Core Coverage Governance Summary

Implemented baseline-aware core-module coverage gating with CI artifact publication and advisory-only non-core reporting.

## Delivered
- Added `tool/coverage/core_module_coverage_check.dart` to parse LCOV, evaluate core path thresholds, and emit machine-readable summary output.
- Added `test/ci/core_module_coverage_policy_test.dart` with policy contract coverage for blocking/advisory/ratchet behavior.
- Added baseline config `.planning/phases/04-test-and-ci-expansion/core-coverage-baseline.json`.
- Wired `coverage-core-gate` stage into `.github/workflows/flutter-ci.yml` to run coverage, enforce core gate, and upload trend artifacts (`summary + lcov`).

## Verification
- `flutter test test/ci/core_module_coverage_policy_test.dart` -> **failed locally** (SDK mismatch).
- `flutter test --coverage && dart run tool/coverage/core_module_coverage_check.dart ...` -> **failed locally** (SDK mismatch and unresolved deps).

## Deviations from Plan
- Runtime verification blocked by local toolchain version; no architecture deviation required.

## Self-Check: PASSED
- Coverage checker, tests, baseline, and CI wiring exist and are committed in `d370fcd`.
