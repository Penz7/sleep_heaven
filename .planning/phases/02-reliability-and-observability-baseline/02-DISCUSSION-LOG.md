# Phase 2: Reliability and Observability Baseline - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in `02-CONTEXT.md`.

**Date:** 2026-04-08
**Phase:** 02-reliability-and-observability-baseline
**Areas discussed:** Startup guardrails, IAP reliability scope, Audio lifecycle contract

---

## Startup Guardrails

| Option | Description | Selected |
|--------|-------------|----------|
| Fail-open | Keep app usable despite most init failures | |
| Fail-fast | Stop app flow on init failures | |
| Hybrid | Fail-open for non-critical, fail-fast for critical | ✓ |

**User's choice:** Hybrid (default lock-in)
**Notes:** Ensure user-safe degraded mode and explicit classification of critical vs non-critical service failures.

---

## IAP Reliability Scope

| Option | Description | Selected |
|--------|-------------|----------|
| Core 5 states | `not_purchased`, `purchased`, `restored`, `failed`, `offline_restore` | ✓ |
| Full matrix | Include pending/cancel/replay/duplicate edge cases in same phase | |
| Minimal | Only purchased/restored | |

**User's choice:** Core 5 states (default lock-in)
**Notes:** Keep deterministic, high-signal reliability scope for Phase 2.

---

## Audio Lifecycle Contract

| Option | Description | Selected |
|--------|-------------|----------|
| Single owner | Active controller owns handler callback registration | ✓ |
| Coordinator service | Central arbitration service for ownership | |
| Event bus | Decouple control routing through bus | |

**User's choice:** Single owner contract + contract tests (default lock-in)
**Notes:** Aligns with existing ownership registration flow in `PlayerController` and `MixerController`.

---

## Claude's Discretion

- Observability provider implementation detail (vendor choice and adapter shape), while keeping phase deliverable for fatal/non-fatal telemetry.
- Error model naming and mapping shape for domain-level failure classification.

## Deferred Ideas

None.
