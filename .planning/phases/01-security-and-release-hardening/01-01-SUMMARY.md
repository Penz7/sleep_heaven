---
phase: 01-security-and-release-hardening
plan: 01
subsystem: infra
tags: [flutter, android-signing, gitleaks, github-actions, pre-commit]
requires: []
provides:
  - Secret handling policy and repository hygiene baseline.
  - Local pre-commit and CI secret scanning gates with deterministic synthetic-secret verification.
  - Hardened Android release signing contract with env-first resolution and fail-fast validation.
affects: [release, security, ci]
tech-stack:
  added: [gitleaks, pre-commit]
  patterns: [env-first signing contract, no-secret logging, fail-fast release validation]
key-files:
  created: [docs/security/secrets.md, .gitleaks.toml, .pre-commit-config.yaml, .github/workflows/secret-scan.yml, test/android_signing_contract_test.dart]
  modified: [.gitignore, android/app/build.gradle.kts]
key-decisions:
  - "Use environment variables as the primary signing source, with local untracked properties fallback."
  - "Use gitleaks in no-git mode in CI to gate active repository content while avoiding historical noise."
patterns-established:
  - "Signing pattern: release requires ANDROID_SIGNING_* values; debug remains secret-file independent."
  - "Scanner pattern: synthetic-secret step validates detector, then full repo scan enforces gate."
requirements-completed: [P1-SEC-01, P1-SEC-02, P1-SEC-03, P1-SEC-04]
duration: 31min
completed: 2026-04-08
---

# Phase 1 Plan 01: Security and Release Hardening Summary

**Android release signing now uses an env-first secure contract with fail-fast validation, and the repo enforces local plus CI secret scanning gates.**

## Performance

- **Duration:** 31 min
- **Started:** 2026-04-07T17:36:21Z
- **Completed:** 2026-04-07T18:07:00Z
- **Tasks:** 3
- **Files modified:** 7

## Accomplishments
- Added concrete secret handling policy and leak response process in `docs/security/secrets.md`.
- Hardened `.gitignore` to block key property variants, env files, and keystore artifacts.
- Added `.gitleaks.toml`, `.pre-commit-config.yaml`, and CI workflow for fail-on-detection secret scanning.
- Refactored `android/app/build.gradle.kts` to support secure env/local signing contract and explicit non-secret release failure messaging.
- Added TDD contract test in `test/android_signing_contract_test.dart` to lock signing behavior.

## Task Commits

Each task was committed atomically:

1. **Task 1: Define secret policy and repository hygiene baseline** - `b84b77b` (feat)
2. **Task 2: Add enforced secret scanning for pre-commit and CI** - `136085c` (feat)
3. **Task 3 (TDD RED): Add failing signing contract test** - `1631fdf` (test)
4. **Task 3 (TDD GREEN): Harden signing contract and scanner integration fixes** - `2b12508` (feat)

## Files Created/Modified
- `docs/security/secrets.md` - signing policy, variable contract, local/CI release commands, incident response.
- `.gitignore` - secret and keystore ignore hardening.
- `.gitleaks.toml` - repo scanner config with targeted allowlist and deterministic synthetic rule.
- `.pre-commit-config.yaml` - local staged-content secret scanning hook.
- `.github/workflows/secret-scan.yml` - CI scanner workflow with synthetic leak proof and fail gate.
- `android/app/build.gradle.kts` - secure signing input contract and release fail-fast validation.
- `test/android_signing_contract_test.dart` - automated contract lock for signing behavior.

## Decisions Made
- Use env-first signing resolution for CI compatibility and reduced local file dependency.
- Keep release failure messages actionable but value-safe by reporting missing key names only.
- Use no-git scanning mode in CI to enforce current tree hygiene while avoiding historic secrets from prior commits.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Local gitleaks binary missing**
- **Found during:** Task 2 verification
- **Issue:** `gitleaks` command not installed on workstation.
- **Fix:** Downloaded temporary runtime binary under `.run/tools/gitleaks` and used it for verification commands.
- **Files modified:** None in committed source.
- **Verification:** `gitleaks version` and subsequent scans executed successfully.
- **Committed in:** N/A (runtime-only)

**2. [Rule 2 - Missing Critical] Scanner self-test originally tripped working-tree scan**
- **Found during:** Task 3 verification
- **Issue:** Synthetic test literal in workflow caused self-detection in normal clean scans.
- **Fix:** Constructed synthetic secret dynamically in workflow shell script and added `.run` path to scanner allowlist.
- **Files modified:** `.github/workflows/secret-scan.yml`, `.gitleaks.toml`
- **Verification:** `gitleaks detect --no-git --source . --config .gitleaks.toml --redact --no-banner` returned no leaks.
- **Committed in:** `2b12508`

---

**Total deviations:** 2 auto-fixed (1 blocking, 1 missing critical)
**Impact on plan:** Required to complete scanner verification and keep secret gates deterministic without reducing security scope.

## Issues Encountered
- Global `flutter test` fails on pre-existing `test/widget_test.dart` dependency-initialization expectations unrelated to this plan’s changed files.

## User Setup Required
None - no external service onboarding required beyond setting Android signing env variables in CI secrets.

## Next Phase Readiness
- Security hardening baseline is in place for signing input handling and secret scanning gates.
- Remaining unrelated test-suite failure should be handled in a dedicated reliability/test-maintenance plan.

## Self-Check: PASSED

