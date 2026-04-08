import 'dart:convert';

import 'package:flutter/services.dart';

import 'feature_flags.dart';

class FeatureFlagService {
  FeatureFlagService._(this._flags);

  final Map<String, bool> _flags;

  static const String defaultAssetPath = 'assets/config/feature_flags.json';

  factory FeatureFlagService.defaults() {
    return FeatureFlagService._(Map<String, bool>.from(FeatureFlags.defaults));
  }

  factory FeatureFlagService.fromMap(Map<String, Object?> payload) {
    final Map<String, bool> merged = Map<String, bool>.from(
      FeatureFlags.defaults,
    );
    for (final MapEntry<String, Object?> entry in payload.entries) {
      if (!FeatureFlags.isKnownFlag(entry.key)) {
        continue;
      }
      merged[entry.key] = _parseBoolean(entry.value);
    }
    return FeatureFlagService._(merged);
  }

  static Future<FeatureFlagService> loadFromAsset({
    AssetBundle? bundle,
    String assetPath = defaultAssetPath,
  }) async {
    final AssetBundle source = bundle ?? rootBundle;
    try {
      final String raw = await source.loadString(assetPath);
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return FeatureFlagService.defaults();
      }
      return FeatureFlagService.fromMap(decoded);
    } catch (_) {
      return FeatureFlagService.defaults();
    }
  }

  bool isEnabled(String flagKey) {
    return _flags[flagKey] ?? false;
  }

  static bool _parseBoolean(Object? value) {
    return value is bool ? value : false;
  }
}
