import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sleep_heaven/core/config/feature_flag_service.dart';
import 'package:sleep_heaven/core/config/feature_flags.dart';
import 'package:sleep_heaven/core/observability/telemetry_config.dart';
import 'package:sleep_heaven/core/observability/telemetry_provider.dart';
import 'package:sleep_heaven/core/observability/telemetry_service.dart';
import 'package:sleep_heaven/core/startup/startup_coordinator.dart';
import 'package:sleep_heaven/main.dart';

class _NoopTelemetryProvider implements TelemetryProvider {
  @override
  Future<void> capture(TelemetryEvent event) async {}
}

class _ThrowingAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    throw const FormatException('invalid');
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    throw const FormatException('invalid');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('startup includes feature flags before iap', () {
    final TelemetryService telemetryService = TelemetryService(
      provider: _NoopTelemetryProvider(),
      config: const TelemetryConfig(enabled: false, provider: 'noop'),
    );
    final steps = buildStartupSteps(telemetryService);
    final int featureFlagIndex = steps.indexWhere(
      (StartupStepConfig step) => step.name == 'feature_flags',
    );
    final int iapIndex = steps.indexWhere(
      (StartupStepConfig step) => step.name == 'iap',
    );

    expect(featureFlagIndex, greaterThanOrEqualTo(0));
    expect(iapIndex, greaterThan(featureFlagIndex));
  });

  test(
    'bootstrap fallbacks to default-off when runtime payload is invalid',
    () async {
      Get.testMode = true;
      Get.reset();
      final TelemetryService telemetryService = TelemetryService(
        provider: _NoopTelemetryProvider(),
        config: const TelemetryConfig(enabled: false, provider: 'noop'),
      );
      final steps = buildStartupSteps(
        telemetryService,
        featureFlagBundle: _ThrowingAssetBundle(),
      );

      final featureStep = steps.firstWhere(
        (step) => step.name == 'feature_flags',
      );
      await featureStep.action();

      final FeatureFlagService service = Get.find<FeatureFlagService>();
      expect(service.isEnabled(FeatureFlags.premiumCatalogGrowth), isFalse);
      expect(
        service.isEnabled(FeatureFlags.premiumIapReliabilityGuardrails),
        isFalse,
      );
    },
  );
}
