# Sleep Heaven Implementation Roadmap

## Planning Basis

- Source inputs: `.planning/codebase/STACK.md`, `INTEGRATIONS.md`, `ARCHITECTURE.md`, `STRUCTURE.md`, `CONVENTIONS.md`, `TESTING.md`, `CONCERNS.md`
- Priority order enforced: **Security + Reliability** -> **Performance + Maintainability** -> **Feature Growth**
- Delivery style: execution-first, phase-gated with validation checks

## Phases

- [x] **Phase 1: Security and Release Hardening** - Eliminate secret-leak risk and harden release pipeline foundations.
- [ ] **Phase 2: Reliability and Observability Baseline** - Add regression prevention, crash visibility, and deterministic app startup behavior.
- [ ] **Phase 3: Performance and Architecture Refactor** - Remove known jank paths and reduce fragile coupling in playback/mixer flow.
- [ ] **Phase 4: Test and CI Expansion** - Scale automated quality gates from smoke tests to integration confidence.
- [ ] **Phase 5: Feature Growth Readiness (IAP + Catalog Evolution)** - Prepare safe feature expansion and post-v1 scaling patterns.

## Phase Details

### Phase 1: Security and Release Hardening
**Goal**: Releases are safely signable and no sensitive material is at accidental commit/exposure risk.
**Requirements**: [P1-SEC-01, P1-SEC-02, P1-SEC-03, P1-SEC-04]
**Depends on**: Nothing
**Estimated scope**: Medium (4-6 focused engineering days)
**Primary risks**:
- Existing local signing material may already be exposed in local history/screenshots.
- No automated secret scanning currently prevents accidental future leaks.
**Deliverables**:
- Secret-handling policy file in repo (`docs/security/secrets.md`) with local + CI handling rules.
- `gitignore`/workspace hygiene cleanup for generated artifacts and local secret files.
- Pre-commit and CI secret scanning gate (example: `gitleaks`) with fail-on-detection.
- Verified Android signing flow that works from secure local env variables/secret file path policy.
**Success Criteria** (what must be TRUE):
  1. A fresh clone can build debug without requiring any committed secret file.
  2. Secret scanner fails CI on test-injected credential patterns.
  3. Release signing can be executed from documented secure setup without editing tracked files.
  4. No sensitive values are printed in build logs under normal release command.
**Validation checks**:
- Run secret scanner against repo and confirm pass/fail behavior.
- Dry-run release build command with secure config and sanitized logs.
- Manual checklist review against `android/key.properties` handling policy.
**Plans**: 1 plan
Plans:
- [ ] `01-01-PLAN.md` - Establish secret hygiene, signed release safety, and enforced secret-scanning gates.
  - Completed: `.planning/phases/01-security-and-release-hardening/01-01-SUMMARY.md`

### Phase 2: Reliability and Observability Baseline
**Goal**: Core playback and purchase flows fail safely, and production issues are diagnosable.
**Depends on**: Phase 1
**Estimated scope**: Medium-Large (6-8 engineering days)
**Primary risks**:
- Audio lifecycle callback handoff is fragile between player, mixer, and handler.
- IAP entitlement transitions are currently under-tested and can regress silently.
- No production crash telemetry means long mean-time-to-diagnosis.
**Deliverables**:
- Crash/error reporting integration (Crashlytics or Sentry) with environment-aware toggles.
- Standardized domain error model for audio, IAP, storage, and permission flows.
- Startup guardrails and health checks around service initialization in app bootstrap.
- Reliability-focused smoke tests for startup, route boot, and IAP service initialization.
**Success Criteria** (what must be TRUE):
  1. Fatal and non-fatal errors from app startup and core services appear in monitoring dashboard.
  2. App startup failure paths show user-safe fallback messaging instead of silent crash loops.
  3. Core IAP states (not purchased, purchased, restored, failed) are reproducible and test-covered.
  4. Audio control handoff between mixer/player can be run repeatedly without orphan state.
**Validation checks**:
- Trigger synthetic handled/unhandled errors and verify telemetry ingestion.
- Run deterministic reliability smoke suite on CI and local.
- Execute manual scenario matrix for purchase restore and playback handoff.
**Plans**: TBD

### Phase 3: Performance and Architecture Refactor
**Goal**: UI interactions stay smooth under realistic usage while reducing change-risk in large feature files.
**Depends on**: Phase 2
**Estimated scope**: Large (8-12 engineering days)
**Primary risks**:
- Performance regressions can reappear without measured budgets.
- Refactoring large UI files may introduce behavior drift if tests are insufficient.
**Deliverables**:
- Refactor eager list rendering in mixer to lazy list strategy with stable item keys.
- Profile-guided optimization for expensive blur/layer usage in mixer UI.
- Split large view files into smaller composable widgets with tighter state scopes.
- Externalize sound catalog metadata to versioned JSON asset with schema validation.
**Success Criteria** (what must be TRUE):
  1. Mixer active list renders lazily and remains smooth during scroll on profile builds.
  2. Core interaction paths show no sustained jank frames in profile timeline checks.
  3. Refactored view modules preserve user-visible behavior from pre-refactor baseline.
  4. Catalog updates can be made by editing metadata asset without controller code edits.
**Validation checks**:
- Profile run measurements captured for before/after on representative device.
- Widget/integration parity checks for player, mixer, home, and library navigation.
- Catalog schema validation test in CI.
**Plans**: TBD
**UI hint**: yes

### Phase 4: Test and CI Expansion
**Goal**: Every merge is gated by meaningful automated checks that prevent regressions.
**Depends on**: Phase 3
**Estimated scope**: Medium (5-7 engineering days)
**Primary risks**:
- Flaky integration tests can reduce trust in CI.
- Overly slow pipelines can be bypassed if feedback loops are poor.
**Deliverables**:
- Multi-stage CI workflow (format/lint -> unit/widget -> integration -> build sanity).
- Test pyramid for services/controllers/providers with mocks/fakes where needed.
- Coverage trend tracking with minimum threshold for core modules.
- Fast-fail PR checks and optional nightly deeper suite.
**Success Criteria** (what must be TRUE):
  1. PRs fail automatically when lint, tests, or critical checks fail.
  2. Core service/controller paths have stable automated tests with actionable failures.
  3. Integration smoke suite validates route boot, playback start/stop, and IAP restore path.
  4. Team can identify regressions from CI output without local reproduction guesswork.
**Validation checks**:
- Open test PRs with intentional failures to verify gate correctness.
- Measure CI runtime and confirm acceptable feedback loop targets.
- Confirm rerun stability of integration jobs.
**Plans**: TBD

### Phase 5: Feature Growth Readiness (IAP + Catalog Evolution)
**Goal**: New premium and content features can be added safely without destabilizing core flows.
**Depends on**: Phase 4
**Estimated scope**: Medium-Large (6-10 engineering days)
**Primary risks**:
- Feature pressure can bypass reliability/performance constraints if gates are weak.
- Catalog growth can inflate bundle and startup costs.
**Deliverables**:
- Feature flag pattern for gated rollouts of new premium capabilities.
- Catalog growth strategy (lazy/deferred loading and content packaging rules).
- IAP lifecycle hardening for edge cases (pending transactions, restore inconsistency, offline states).
- Release checklist with security/reliability/performance sign-off criteria.
**Success Criteria** (what must be TRUE):
  1. New premium features can be toggled on/off safely without release rebuild churn.
  2. Catalog growth does not materially degrade startup and playback responsiveness.
  3. IAP recovery paths handle interruptions and restore edge cases predictably.
  4. Release go/no-go can be decided from objective checklist evidence.
**Validation checks**:
- Feature-flag toggling tests across app startup and runtime.
- App size/performance comparison report against baseline.
- IAP edge-case scenario runbook executed before release cut.
**Plans**: TBD

## First 2 Weeks Execution Plan

### Week 1 (Security + Reliability Foundations)
- **Day 1**: Finalize security baseline
  - Confirm secret exposure surfaces (`key.properties`, local build files, logs).
  - Add/update ignore rules for generated and local-only sensitive files.
  - Define secure signing setup doc and local onboarding steps.
- **Day 2**: Add secret scanning gates
  - Add pre-commit secret scan hook.
  - Add CI secret-scan job with clear fail messaging.
  - Validate with synthetic leaked-token test string.
- **Day 3**: Bootstrap reliability scaffolding
  - Add app-wide error wrapper and structured domain error types.
  - Add startup health checks for core services (audio, storage, IAP).
- **Day 4**: Integrate observability
  - Add crash/error SDK and route startup/service exceptions to reporting.
  - Add environment toggles for debug/profile/release reporting behavior.
- **Day 5**: Create reliability smoke tests
  - Replace default counter widget test with app-specific startup/route smoke tests.
  - Add first IAP initialization state tests with mocked store stream.

### Week 2 (Reliability Completion + Performance Entry)
- **Day 6**: Audio lifecycle stabilization
  - Add explicit handoff contract tests for player <-> mixer <-> audio handler callbacks.
  - Fix callback registration/cleanup asymmetry if detected.
- **Day 7**: IAP transition reliability
  - Add deterministic tests for purchase success/failure/restore/offline transitions.
  - Ensure secure-storage entitlement state updates are idempotent.
- **Day 8**: Performance quick wins
  - Migrate eager mixer list rendering to lazy builder.
  - Add stable keys and review rebuild boundaries.
- **Day 9**: Profile + tune
  - Run profile measurements on physical Android device.
  - Reduce expensive blur/layer hotspots where jank is confirmed.
- **Day 10**: CI phase-1 completion
  - Wire pipeline order: format/analyze -> unit/widget -> smoke integration -> build sanity.
  - Set pass criteria and publish first quality dashboard snapshot.

## Suggested Order: Tests and CI Improvements

1. Replace invalid default widget test with app bootstrap smoke tests.
2. Add unit tests for `IAPService` state machine and entitlement persistence.
3. Add unit/controller tests for audio handler callback lifecycle.
4. Add repository/provider tests for Hive/local storage invariants.
5. Add integration smoke tests for startup -> playback -> timer -> restore purchase.
6. Create CI pipeline with staged fail-fast order (analysis -> tests -> integration -> build).
7. Add nightly extended suite (performance profile checks + release build sanity + dependency audit).

## Blockers Before Scaling Development

1. **No CI quality gates**: currently blocks reliable parallel feature delivery.
2. **No production observability**: blocks fast diagnosis and incident response.
3. **Signing secret handling risk**: blocks safe release automation and compliance confidence.
4. **Fragile audio lifecycle coupling**: blocks safe expansion of playback features.
5. **IAP transition test gap**: blocks confident monetization changes.
6. **Monolithic UI modules**: blocks rapid, low-risk iteration in mixer/player flows.
7. **Static catalog in code**: blocks scalable content operations.

## Progress Table

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Security and Release Hardening | 1/1 | Complete | 2026-04-08 |
| 2. Reliability and Observability Baseline | 0/4 | Not started | - |
| 3. Performance and Architecture Refactor | 0/4 | Not started | - |
| 4. Test and CI Expansion | 0/3 | Not started | - |
| 5. Feature Growth Readiness (IAP + Catalog Evolution) | 0/3 | Not started | - |
