# Project State - Sleep Heaven

## Project Reference
- **Core value**: Deliver a stable, secure, premium sleep-audio experience with reliable playback and monetization.
- **Roadmap source**: `.planning/ROADMAP.md`
- **Current focus**: Phase 5 - Feature Growth Readiness (IAP + Catalog Evolution)

## Current Position
- **Current phase**: 5
- **Current plan**: 03 complete
- **Status**: Phase 5 implemented and verified locally
- **Progress**: 100%
- **Immediate next milestone**: Open Phase 5 shipping PR

## Performance Metrics Baseline
- **Automated test maturity**: Baseline (signing contract + GetX/Hive/IAP bootstrap smoke)
- **CI maturity**: `secret-scan` + `flutter-ci` (analyze, test, debug APK) on PR/push
- **Observability maturity**: Baseline established (Sentry adapter + startup/service capture)
- **Security posture (repo/process)**: At risk due to signing secret handling process gaps
- **Reliability confidence**: Medium-high for startup, IAP, and audio ownership contracts

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
- Startup/performance regressions if new flows bypass startup coordinator conventions
- Playback UI jank risk remains until Phase 3 list/layer profiling work

### Open Blockers
- None currently blocking roadmap execution.

## Session Continuity
- **Last completed artifact**: `.planning/phases/04-test-and-ci-expansion/04-03-SUMMARY.md`
- **Shipping**: `phase-04-test-ci-expansion-ship` pushed to `origin` (2026-04-08). Open PR: https://github.com/Penz7/sleep_heaven/pull/4
- **Next action**: Merge PR #4, then run `/gsd-discuss-phase 5`
- **Execution rhythm**: Daily evidence-driven closeout (deliverable + validation check)

## Decision Log
- Chosen phase structure prioritizes release safety and regression control before optimization/features.
- CI/test ordering is fail-fast by design to reduce wasted build time.
- Performance work is intentionally delayed until reliability baselines and observability exist.
- Use env-first Android signing (`ANDROID_SIGNING_*`) with local untracked fallback (`key.properties.local`) for secure and reproducible release builds.
- Use local pre-commit and CI `gitleaks` scanning with deterministic synthetic-secret verification and redacted output.
- Lock telemetry provider behind `TelemetryProvider` and route all startup/service failures through `DomainError`.
- Keep `IAPService` singleton contract intact while enforcing deterministic five-state and reconciliation behavior.
- Enforce single-owner latest-wins callback ownership contract in `SleepAudioHandler` and dependent controllers.
- Adopt `ListView.builder` with stable `ValueKey(soundId)` for mixer active list to reduce eager rendering overhead while preserving UI parity.
- Split `mixer_view.dart` into section modules (header, active sounds, bottom actions) without changing `MixerController` contracts.
- Externalize sound catalog to `assets/catalog/sound_catalog.v1.json` with schema validation and CI contract tests.
- Adopt typed fail-closed feature flags initialized before IAP startup.
- Use bounded catalog startup slice loading with warmup limit guardrails.
- Harden IAP pending/restore inconsistency transitions and tie release sign-off to CI evidence.
