---
phase: 04-test-and-ci-expansion
plan: 01
status: completed-with-blocked-local-verification
commit: 49ceb1c
---

# Phase 4 Plan 01: CI Stage Architecture Summary

Implemented strict fail-fast CI stage ordering and a separate nightly workflow lane with quarantine visibility metadata.

## Delivered
- Refactored `.github/workflows/flutter-ci.yml` into ordered stages with explicit `needs`: `format-lint-analyze` -> `unit-widget` -> `integration-smoke` -> `build-sanity`.
- Added deterministic stage bounds via `timeout-minutes` and explicit anti-flake comments for workflow-level reruns only.
- Added `.github/workflows/flutter-nightly.yml` with `schedule` + `workflow_dispatch`, extended checks, and quarantine lane owner metadata.

## Verification
- `flutter --version && flutter analyze && flutter test` -> **failed locally** (SDK mismatch: Dart 3.10.7 vs required ^3.10.8).
- `gh workflow view flutter-nightly.yml` -> **404 on default branch** (expected pre-push for new workflow file).
- `node -e "...existsSync..."` -> **pass**.

## Deviations from Plan
- None for implementation scope.
- Local runtime verification is blocked by host Flutter SDK version.

## Self-Check: PASSED
- Workflow files exist and are committed in `49ceb1c`.
