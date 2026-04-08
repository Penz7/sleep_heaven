# Phase 2: Reliability and Observability Baseline - Context

**Gathered:** 2026-04-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Harden runtime reliability for startup, IAP transitions, and audio ownership handoff so core flows fail safely and are diagnosable. This phase does not add new user features.

</domain>

<decisions>
## Implementation Decisions

### Startup Guardrails
- **D-01:** Use hybrid startup policy: fail-open with degraded mode for non-critical services, fail-fast only for critical blockers.
- **D-02:** Startup must initialize services in explicit order with error classification: critical vs non-critical, then route app state accordingly.
- **D-03:** Non-critical initialization failures must surface user-safe fallback messaging and telemetry events, never silent no-op.

### IAP Reliability Scope
- **D-04:** Lock Phase 2 automated reliability coverage to 5 mandatory states: `not_purchased`, `purchased`, `restored`, `failed`, `offline_restore`.
- **D-05:** Tests must verify entitlement cache + stream reconciliation behavior, including startup restore behavior under offline/online transitions.
- **D-06:** Keep existing service contract (`IAPService` as app-lifetime singleton) and add deterministic test harness around it rather than refactor architecture in this phase.

### Audio Lifecycle Contract
- **D-07:** Keep single-owner callback contract for `SleepAudioHandler` where active controller owns `onPlayRequested`/`onPauseRequested`.
- **D-08:** Add explicit ownership handoff contract tests for `PlayerController` and `MixerController` to prevent orphan callbacks and stale control routing.
- **D-09:** Ownership transitions must preserve lock-screen/notification correctness and never leave handler in ambiguous state.

### Observability Direction
- **D-10:** Integrate one production crash/error reporting provider in this phase (planner may select specific vendor), with environment-aware toggles.
- **D-11:** Capture fatal + non-fatal startup/service errors with consistent domain tags (`startup`, `iap`, `audio`, `storage`, `permission`).

### Claude's Discretion
- Exact telemetry SDK selection and adapter layering details.
- Concrete error model type names and serialization shape.
- CI job split granularity for reliability suites.

</decisions>

<specifics>
## Specific Ideas

- Prioritize reliability over feature velocity: no new capability creep in this phase.
- Preserve current GetX + singleton service model; improve contracts/tests first.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase definition
- `.planning/ROADMAP.md` — Phase 2 goal, deliverables, success criteria, validation checks.
- `.planning/STATE.md` — active risks, current maturity baseline, sequencing constraints.

### Startup and service bootstrap
- `lib/main.dart` — bootstrap sequence for `SleepAudioHandler`, `HiveProvider`, `IAPService`.

### IAP runtime behavior
- `lib/core/services/iap_service.dart` — purchase stream handling, restore logic, entitlement cache behavior.

### Audio ownership and handoff
- `lib/core/services/audio_handler.dart` — callback ownership model and notification state API.
- `lib/features/player/controllers/player_controller.dart` — player-side ownership registration and lifecycle hooks.
- `lib/features/mixer/controllers/mixer_controller.dart` — mixer-side ownership registration and lifecycle hooks.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `IAPService` already models purchase states via `purchaseStream` and secure storage cache; extend with deterministic tests instead of rewriting service.
- `SleepAudioHandler` already centralizes notification and media control callbacks; use as contract surface for handoff tests.

### Established Patterns
- App bootstrap uses ordered async initialization in `main.dart` with permanent GetX service registration.
- Controllers use explicit ownership assignment into `SleepAudioHandler` before playback starts.

### Integration Points
- Startup guardrail/error classification should wrap `main.dart` service init boundaries.
- Reliability tests should target `IAPService`, `PlayerController`, `MixerController`, and bootstrap route behavior.
- Observability hooks should be wired at startup boundaries and service error branches.

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 02-reliability-and-observability-baseline*
*Context gathered: 2026-04-08*
