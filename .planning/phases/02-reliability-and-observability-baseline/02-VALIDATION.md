# Phase 2 Validation (Nyquist)

**Phase:** `02-reliability-and-observability-baseline`  
**Nyquist applicable:** Yes  
**Status:** Revised plan coverage includes explicit automated validation paths

## Validation Scope

- Startup reliability classification and routing (`critical` vs `non-critical`)
- Route boot outcomes (normal, degraded, fatal block)
- Telemetry provider wiring and configuration artifacts
- Synthetic telemetry ingestion for handled and unhandled failures
- IAP 5-state reliability matrix and startup reconciliation
- Audio single-owner handoff contract behavior

## Requirement-to-Verification Matrix

| Requirement | Verification target | Automated command |
|---|---|---|
| `P2-REL-STARTUP` | Startup coordinator behavior + route boot smoke outcomes | `flutter test test/startup/startup_coordinator_test.dart test/startup/bootstrap_route_smoke_test.dart` |
| `P2-OBS-TELEMETRY` | Telemetry tagging + handled/unhandled ingestion proof | `flutter test test/observability/telemetry_service_test.dart test/observability/telemetry_ingestion_proof_test.dart` |
| `P2-REL-IAP` | 5-state IAP matrix + offline/online restore reconciliation | `flutter test test/services/iap/iap_service_reliability_test.dart test/startup/iap_startup_restore_reconciliation_test.dart` |
| `P2-REL-AUDIO` | Player/mixer ownership handoff contract | `flutter test test/services/audio/audio_handoff_contract_test.dart` |

## Telemetry Wiring Evidence Artifacts

The following artifacts are explicitly required by revised plans:

- `lib/core/observability/telemetry_provider.dart`
- `lib/core/observability/telemetry_config.dart`
- `lib/core/observability/telemetry_service.dart`
- `pubspec.yaml` (provider dependency lock)
- `test/observability/telemetry_ingestion_proof_test.dart`

## Phase Gate Command Set

Run all phase checks before marking Phase 2 complete:

```bash
flutter test test/startup/startup_coordinator_test.dart test/startup/bootstrap_route_smoke_test.dart
flutter test test/observability/telemetry_service_test.dart test/observability/telemetry_ingestion_proof_test.dart
flutter test test/services/iap/iap_service_reliability_test.dart test/startup/iap_startup_restore_reconciliation_test.dart
flutter test test/services/audio/audio_handoff_contract_test.dart
```

## Exit Criteria

- Every requirement row above has a passing command.
- Startup route boot smoke tests prove normal/degraded/fatal routing.
- Synthetic handled/unhandled telemetry ingestion tests pass.
- Telemetry provider lock and config artifacts exist and are wired.
