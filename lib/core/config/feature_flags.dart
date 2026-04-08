class FeatureFlags {
  static const String premiumCatalogGrowth = 'premium.catalog_growth';
  static const String premiumIapReliabilityGuardrails =
      'premium.iap_reliability_guardrails';

  static const Map<String, bool> defaults = <String, bool>{
    premiumCatalogGrowth: false,
    premiumIapReliabilityGuardrails: false,
  };

  static bool isKnownFlag(String flagKey) => defaults.containsKey(flagKey);
}
