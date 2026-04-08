---
phase: 02-reliability-and-observability-baseline
plan: 01
subsystem: infra
tags: [flutter, startup, telemetry, sentry, reliability]
requires: []
provides:
  - Typed domain error model with startup/service domain tags
  - Provider-backed telemetry service with environment gating
  - Startup coordinator with critical vs non-critical fail policy
  - Degraded and fatal startup routing coverage
affects: [iap, audio, observability, startup]
tech-stack:
  added: [sentry_flutter]
  patterns: [domain-error-envelope, startup-step-classification, centralized-telemetry-capture]
key-files:
  created:
    - lib/core/errors/domain_error.dart
    - lib/core/observability/telemetry_service.dart
    - lib/core/startup/startup_coordinator.dart
    - test/startup/bootstrap_route_smoke_test.dart
  modified:
    - lib/main.dart
    - pubspec.yaml
    - pubspec.lock
key-decisions:
  - "Lock telemetry provider behind adapter contract and keep app-facing API provider-agnostic."
  - "Treat audio/storage as critical startup steps, and IAP as non-critical degraded path."
patterns-established:
  - "All startup and service failures normalize into DomainError before telemetry capture."
  - "Bootstrap executes in explicit ordered StartupStepConfig entries with deterministic classification."
requirements-completed: [P2-REL-STARTUP, P2-OBS-TELEMETRY]
duration: 52min
completed: 2026-04-08
---

# Phase 2 Plan 01: Reliability and Observability Baseline Summary

**Hybrid startup guardrails and Sentry-backed telemetry capture now enforce fail-fast/fail-open startup behavior with deterministic degraded/fatal routing.**

## Performance

- **Duration:** 52 min
- **Started:** 2026-04-08T19:09:00Z
- **Completed:** 2026-04-08T20:01:00Z
- **Tasks:** 3
- **Files modified:** 20

## Accomplishments
- Implemented `DomainError` + telemetry contracts with required domain tagging.
- Added startup coordinator with explicit criticality map and degraded UX surface.
- Proved handled/unhandled error ingestion paths through telemetry-focused tests.

## Task Commits

Each task was committed atomically:

1. **Task 1: Implement typed reliability/telemetry contracts for startup and services** - `3d997c2` (chore)
2. **Task 2: Add hybrid startup coordinator and degraded/fatal routing** - `f635e5e` (feat)
3. **Task 3: Prove handled and unhandled telemetry ingestion paths** - `435206b` (test)

## Files Created/Modified
- `lib/core/errors/domain_error.dart` - Typed error domain/severity envelope.
- `lib/core/observability/telemetry_service.dart` - Unified capture contract and provider dispatch.
- `lib/core/observability/telemetry_provider.dart` - Provider adapter abstraction with Sentry implementation.
- `lib/core/startup/startup_coordinator.dart` - Ordered startup orchestration with critical/non-critical branching.
- `lib/main.dart` - Boot pipeline, global error handlers, degraded/fatal routing.
- `test/observability/telemetry_service_test.dart` - Fatal/non-fatal/tagging/toggle verification.
- `test/startup/startup_coordinator_test.dart` - Criticality and execution-order checks.
- `test/startup/bootstrap_route_smoke_test.dart` - Normal/degraded/fatal route smoke validation.

## Decisions Made
- Locked Sentry behind `TelemetryProvider` so future provider swaps do not affect callers.
- Implemented startup as explicit step list to avoid implicit ordering drift.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Flutter toolchain path mismatch during verification**
- **Found during:** Task 1 verification
- **Issue:** Default shell `flutter` resolved to 3.38.8/Dart 3.10.7, failing SDK constraint `^3.10.8`.
- **Fix:** Executed verification with pinned Flutter 3.41.6 binary and committed `.fvmrc` pin.
- **Files modified:** `.fvmrc`
- **Verification:** All plan verification tests passed with Flutter 3.41.6 / Dart 3.11.4.
- **Committed in:** `3d997c2`

---

**Total deviations:** 1 auto-fixed (Rule 3: 1)
**Impact on plan:** Required to unblock execution and align environment with declared SDK constraints.

## Known Stubs
None.

## Issues Encountered
- Initial verification attempt failed due to stale shell Flutter path; resolved by explicit SDK path.

## Threat Flags
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Telemetry and startup reliability contracts are stable for IAP/audio hardening in Plans 02-02 and 02-03.

## Self-Check: PASSED

---
*Phase: 02-reliability-and-observability-baseline*
*Completed: 2026-04-08*
