# Release Go/No-Go Checklist

## Security Evidence
- [ ] `flutter analyze` passes with no new high-severity findings.
- [ ] Secret scan job passes (`gitleaks` in CI workflow).
- [ ] Signing inputs are sourced from secure env/local secret files only.

## Reliability Evidence
- [ ] `flutter test test/services/iap/iap_service_reliability_test.dart` passes.
- [ ] `flutter test test/startup/iap_startup_restore_reconciliation_test.dart` passes.
- [ ] `flutter test test/startup/feature_flag_bootstrap_test.dart` passes.

## Performance Evidence
- [ ] `flutter test test/data/catalog/catalog_growth_loading_test.dart test/data/catalog/catalog_startup_budget_test.dart` passes.
- [ ] Startup warmup remains bounded (`LocalSoundProvider.startupWarmupLimit` contract).

## Decision
- **Go** only when every item is checked with CI evidence links.
- **No-Go** if any required check fails or evidence is missing.
