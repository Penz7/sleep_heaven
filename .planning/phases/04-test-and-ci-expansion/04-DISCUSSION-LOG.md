# Phase 4: Test and CI Expansion - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md - this log preserves the alternatives considered.

**Date:** 2026-04-08
**Phase:** 04-test-and-ci-expansion
**Areas discussed:** CI stage architecture + trigger policy, integration smoke scope + flake control, coverage policy + thresholds, test pyramid ownership

---

## CI Stage Architecture + Trigger Policy

| Option | Description | Selected |
|--------|-------------|----------|
| Multi-stage fail-fast pipeline (recommended) | Split gates by stage with explicit ordering and blocking semantics. | ✓ |
| Keep monolithic single CI job | Simpler YAML, but lower diagnosis quality and weaker gate visibility. | |
| Aggressive matrix from PR stage | High confidence but likely slower PR feedback and higher infra cost. | |

**User's choice:** Auto -> Multi-stage fail-fast pipeline (recommended default)
**Notes:** Lock fast feedback on PR/push; move heavy suites to nightly.

---

## Integration Smoke Scope + Flake Control

| Option | Description | Selected |
|--------|-------------|----------|
| Critical-flow smoke set + deterministic anti-flake policy (recommended) | Cover startup/playback/IAP-restore with bounded retries and quarantine discipline. | ✓ |
| Broad integration-by-default | Wider coverage but higher flake risk and slower PR cycle. | |
| Minimal smoke only on startup | Fastest runtime but misses key monetization/playback regressions. | |

**User's choice:** Auto -> Critical-flow smoke set + deterministic anti-flake policy (recommended default)
**Notes:** Enforce explicit quarantine lane instead of silently disabling flaky tests.

---

## Coverage Policy + Thresholds

| Option | Description | Selected |
|--------|-------------|----------|
| Core-module gate + ramped thresholds (recommended) | Gate critical modules now, advisory elsewhere, raise bar incrementally after stable baseline. | ✓ |
| One global strict threshold immediately | Simple rule, but high risk of noisy failures and low adoption. | |
| Coverage fully advisory | Low friction, but weak merge protection against regression. | |

**User's choice:** Auto -> Core-module gate + ramped thresholds (recommended default)
**Notes:** Keep trend reporting visible in CI artifacts.

---

## Test Pyramid Ownership

| Option | Description | Selected |
|--------|-------------|----------|
| Unit/service/controller-first with explicit fakes at platform boundaries (recommended) | Fast and deterministic tests, integration reserved for critical path validation. | ✓ |
| Integration-heavy strategy | Higher end-to-end confidence but slower and more flaky under CI. | |
| Widget-first expansion | Useful for UI wiring but weaker for service reliability contracts. | |

**User's choice:** Auto -> Unit/service/controller-first with explicit fakes (recommended default)
**Notes:** Avoid real plugin channels in CI tests; keep widget smoke focused.

---

## Claude's Discretion

- Exact workflow split strategy and naming for CI/nightly files.
- Module-by-module threshold numbers and ratchet schedule.
- Coverage artifact publication format and reporting style.

## Deferred Ideas

- Full device-farm E2E and broad performance benchmark automation deferred to future phase after Phase 4 baseline.
