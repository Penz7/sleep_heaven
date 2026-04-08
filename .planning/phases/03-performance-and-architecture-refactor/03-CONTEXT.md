# Phase 3: Performance and Architecture Refactor - Context

**Gathered:** 2026-04-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Improve runtime UI performance and reduce architecture risk by refactoring mixer rendering, optimizing blur-heavy UI paths, splitting oversized view modules, and externalizing sound catalog metadata. No new product capability is added in this phase.

</domain>

<decisions>
## Implementation Decisions

### Mixer List Rendering
- **D-01:** Refactor mixer active sounds from eager `ListView(children: ...)` to lazy `ListView.builder` with stable `ValueKey(soundId)`.
- **D-02:** Extract track tile and section header into dedicated widgets to reduce rebuild surface area and keep list virtualization effective.
- **D-03:** Preserve current visual behavior and controls while changing rendering strategy; parity is mandatory.

### Blur/Glass Performance Policy
- **D-04:** Use adaptive degrade policy for blur/glass effects based on performance tier/profile evidence instead of always-on full blur.
- **D-05:** Keep glass style as default on capable devices; apply fallback (reduced sigma/simpler decoration) on constrained paths to protect frame budget.

### Module Split Strategy
- **D-06:** Apply section-first split for large view files (header/list/bottom/action panel/components) before deep feature-slice restructuring.
- **D-07:** Keep controller/service contracts stable during split; this phase optimizes structure/perf, not domain behavior.

### Catalog Externalization
- **D-08:** Externalize sound catalog to versioned JSON assets with schema-first validation in CI.
- **D-09:** Add backward-compatible loader/cache layer so catalog edits do not require controller code changes.

### Claude's Discretion
- Exact tier thresholds and fallback heuristics for blur degradation.
- Concrete file/module names for section extraction as long as boundaries above are preserved.
- JSON schema tooling details and cache invalidation internals.

</decisions>

<specifics>
## Specific Ideas

- Keep refactor incremental and profile-driven; each performance decision must have measurable before/after evidence.
- Preserve user-facing parity while reducing jank risk and future maintenance cost.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase contract
- `.planning/ROADMAP.md` — Phase 3 goal, deliverables, success criteria, validation checks.
- `.planning/STATE.md` — current maturity baseline and sequencing constraints.

### Mixer rendering hotspot
- `lib/features/mixer/views/mixer_view.dart` — eager active-list rendering and blur-heavy UI composition.

### Asset/catalog baseline
- `lib/core/constants/app_assets.dart` — current static asset path contract used by runtime code.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- Existing mixer card components and active-sound widgets can be reused after extraction; visual parity should come from reusing current card composition.

### Established Patterns
- GetX controllers/services are stable from Phase 2; UI refactor should avoid changing core ownership contracts.
- Current active list path uses eager spread over `tracks.entries`, which is the direct virtualization target.

### Integration Points
- `mixer_view.dart` is primary performance/refactor integration point for list + blur policy.
- Catalog externalization will touch repository/provider loading path that currently assumes in-code/static metadata.
- CI validation must include schema check for external catalog payload.

</code_context>

<deferred>
## Deferred Ideas

- Mixer background/lock-screen parity with player (run in background and lock-screen controls) is a new capability and should be planned as a separate future phase after Phase 3 scope closes.

</deferred>

---

*Phase: 03-performance-and-architecture-refactor*
*Context gathered: 2026-04-08*
