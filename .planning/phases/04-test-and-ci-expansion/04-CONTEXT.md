# Phase 4: Test and CI Expansion - Context

**Gathered:** 2026-04-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Scale quality gates from current baseline into a deterministic, fast-fail CI + test pyramid that blocks regressions before merge. Scope is quality infrastructure and test strategy only; no new end-user feature capability is added in this phase.

</domain>

<decisions>
## Implementation Decisions

### CI Stage Architecture and Trigger Policy
- **D-01:** Use strict fail-fast stage order in CI: `format/lint/analyze` -> `unit+widget` -> `integration smoke` -> `build sanity`.
- **D-02:** Run merge-blocking gates on both `pull_request` and `push` to active branches; keep full signal parity between local contributor flow and PR flow.
- **D-03:** Add a separate nightly extended workflow for slower confidence jobs (longer integration matrix, dependency audit, release sanity) so PR cycle remains fast.

### Integration Smoke Scope and Flake Control
- **D-04:** Lock mandatory integration smoke scope to three critical flows: startup route boot, playback start/stop path, and IAP restore reconciliation path.
- **D-05:** Enforce deterministic anti-flake policy: fixed test environment setup, explicit timeout budgets per suite, and bounded retry policy only at workflow/job level (not hidden test-level infinite retries).
- **D-06:** If a smoke test is flaky, quarantine by explicit label/workflow lane with owner follow-up; do not silently disable failing checks.

### Coverage Policy and Thresholds
- **D-07:** Track line coverage trend in CI artifacts and enforce minimum threshold gate first on core modules (`core/services`, `core/startup`, `features/*/controllers`, provider/repository layer), then expand gradually.
- **D-08:** Start with practical threshold ramp (baseline-aware) rather than unrealistic global hard target; ratchet upward only after stable green runs.
- **D-09:** Treat coverage as a merge gate for core modules and advisory for non-core modules in this phase.

### Test Pyramid Ownership and Doubles Strategy
- **D-10:** Prioritize fast unit/service/controller tests before broader integration expansion; widget tests remain focused on wiring/parity and route smoke.
- **D-11:** Standardize on explicit fakes/stubs for platform/plugin boundaries (IAP, path_provider, connectivity, audio callbacks) and avoid real platform channels in CI tests.
- **D-12:** Keep integration tests thin and behavior-critical; business logic correctness should primarily live in unit/service/controller suites.

### Claude's Discretion
- Exact workflow file split naming (`flutter-ci`, `flutter-nightly`, etc.) and matrix shape.
- Concrete threshold numbers per package/module as long as ramp strategy and core gating policy above are preserved.
- Tooling details for coverage reporting publication (artifact format and summarization style).

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase contract
- `.planning/ROADMAP.md` - Phase 4 goal, deliverables, success criteria, and validation checks.
- `.planning/STATE.md` - Current project position, locked sequencing priorities, and CI/test maturity baseline.

### Existing CI baseline
- `.github/workflows/flutter-ci.yml` - Current analyze/test/build gate baseline to evolve into multi-stage flow.
- `.github/workflows/secret-scan.yml` - Existing security gate pattern and workflow trigger conventions.

### Existing critical test baselines
- `test/startup/bootstrap_route_smoke_test.dart` - Startup route boot smoke coverage.
- `test/services/audio/audio_handoff_contract_test.dart` - Audio lifecycle/ownership reliability baseline.
- `test/services/iap/iap_service_reliability_test.dart` - Core IAP reliability state matrix baseline.
- `test/startup/iap_startup_restore_reconciliation_test.dart` - Startup restore reconciliation behavior baseline.
- `test/widget_test.dart` - Main-style app binding bootstrap smoke contract.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- Existing reliability suites already cover startup/IAP/audio contracts and can be promoted into explicit CI stage gates.
- Catalog contract tests and signing contract tests provide a pattern for requirement-specific CI checks.

### Established Patterns
- Current CI already runs analyze -> test -> debug APK in one job; phase work should split this into clearer gated stages while preserving fail-fast behavior.
- Tests use GetX singleton bootstrap patterns and fake/stub injection for deterministic runtime contracts.

### Integration Points
- Primary integration point is `.github/workflows/flutter-ci.yml` (stage decomposition + gate policy).
- Secondary integration point is the `test/` suite structure (unit/widget/integration labeling and ownership boundaries).
- Coverage reporting and threshold enforcement will attach to CI output/artifacts and module path conventions.

</code_context>

<specifics>
## Specific Ideas

- Keep PR feedback loop tight: fast-fail checks must complete quickly and clearly signal root cause.
- Prefer deterministic CI behavior over maximal test breadth on PR runs; push deeper checks to nightly lane.

</specifics>

<deferred>
## Deferred Ideas

- Full E2E device farm matrix and broad performance benchmark automation should be considered as a future dedicated phase after Phase 4 baseline stabilization.

</deferred>

---

*Phase: 04-test-and-ci-expansion*
*Context gathered: 2026-04-08*
