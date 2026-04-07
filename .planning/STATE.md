# Project State - Sleep Heaven

## Project Reference
- **Core value**: Deliver a stable, secure, premium sleep-audio experience with reliable playback and monetization.
- **Roadmap source**: `.planning/ROADMAP.md`
- **Current focus**: Phase 1 - Security and Release Hardening

## Current Position
- **Current phase**: 1
- **Current plan**: 01 completed
- **Status**: Phase 1 Plan 01 complete
- **Progress**: 20%
- **Immediate next milestone**: Security baseline and CI secret scanning active

## Performance Metrics Baseline
- **Automated test maturity**: Very low (default scaffold test only)
- **CI maturity**: None detected
- **Observability maturity**: None detected
- **Security posture (repo/process)**: At risk due to signing secret handling process gaps
- **Reliability confidence**: Low for IAP and audio lifecycle transitions

## Accumulated Context

### Confirmed Constraints
- Flutter + GetX architecture with local-first storage and in-app purchase integration.
- Android signing uses local key properties; handling policy needs hardening.
- No backend API dependency required for core roadmap sequencing.

### Priority Order (Locked)
1. Security and reliability first
2. Performance and maintainability second
3. Feature growth third

### Known High-Risk Areas
- Secret leakage risk around signing configuration handling
- Audio handler callback lifecycle coupling across controllers
- IAP entitlement transition edge cases without sufficient automated coverage
- No crash telemetry and no CI quality gates

### Open Blockers
- Default widget smoke test is failing due app bootstrap dependency setup and should be replaced by app-specific tests.
- No production-grade error tracking

## Session Continuity
- **Last completed artifact**: `.planning/phases/01-security-and-release-hardening/01-01-SUMMARY.md`
- **Next action**: Start Phase 2 reliability and observability baseline planning/execution
- **Execution rhythm**: Daily evidence-driven closeout (deliverable + validation check)

## Decision Log
- Chosen phase structure prioritizes release safety and regression control before optimization/features.
- CI/test ordering is fail-fast by design to reduce wasted build time.
- Performance work is intentionally delayed until reliability baselines and observability exist.
- Use env-first Android signing (`ANDROID_SIGNING_*`) with local untracked fallback (`key.properties.local`) for secure and reproducible release builds.
- Use local pre-commit and CI `gitleaks` scanning with deterministic synthetic-secret verification and redacted output.
