import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_heaven/core/config/feature_flag_service.dart';
import 'package:sleep_heaven/core/config/feature_flags.dart';

void main() {
  group('FeatureFlagService', () {
    test('known premium flags resolve to expected typed values', () {
      final FeatureFlagService service =
          FeatureFlagService.fromMap(<String, Object?>{
            FeatureFlags.premiumCatalogGrowth: true,
            FeatureFlags.premiumIapReliabilityGuardrails: true,
          });

      expect(service.isEnabled(FeatureFlags.premiumCatalogGrowth), isTrue);
      expect(
        service.isEnabled(FeatureFlags.premiumIapReliabilityGuardrails),
        isTrue,
      );
    });

    test('missing flags use default-off premium fallback', () {
      final FeatureFlagService service = FeatureFlagService.fromMap(
        const <String, Object?>{},
      );

      expect(service.isEnabled(FeatureFlags.premiumCatalogGrowth), isFalse);
      expect(
        service.isEnabled(FeatureFlags.premiumIapReliabilityGuardrails),
        isFalse,
      );
    });

    test('invalid payload values fail closed', () {
      final FeatureFlagService service =
          FeatureFlagService.fromMap(<String, Object?>{
            FeatureFlags.premiumCatalogGrowth: 'true',
            FeatureFlags.premiumIapReliabilityGuardrails: 1,
          });

      expect(service.isEnabled(FeatureFlags.premiumCatalogGrowth), isFalse);
      expect(
        service.isEnabled(FeatureFlags.premiumIapReliabilityGuardrails),
        isFalse,
      );
    });
  });
}
