# Project State - Sleep Heaven

## Project Reference
- **Core value**: Deliver a stable, secure, premium sleep-audio experience with reliable playback and monetization.
- **Roadmap source**: `.planning/ROADMAP.md`
- **Current focus**: Phase 4 - Test and CI Expansion

## Current Position
- **Current phase**: 4
- **Current plan**: pending kickoff
- **Status**: Phase 3 shipped (PR #3 opened)
- **Progress**: 70%
- **Immediate next milestone**: Merge PR #3, then execute Phase 4 plans

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
- **Last completed artifact**: `.planning/phases/02-reliability-and-observability-baseline/02-03-SUMMARY.md`
- **Shipping**: `phase-03-performance-refactor-ship` pushed to `origin` (2026-04-08). Open PR: https://github.com/Penz7/sleep_heaven/pull/3
- **Next action**: Run `/gsd-progress` or start `/gsd-execute-phase 4` after PR #3 CI passes/merges
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
