import 'package:flutter/foundation.dart';

class TelemetryConfig {
  const TelemetryConfig({
    required this.enabled,
    required this.provider,
    this.environment = 'local',
  });

  final bool enabled;
  final String provider;
  final String environment;

  static const String sentryProvider = 'sentry';

  factory TelemetryConfig.fromEnvironment() {
    const bool forceEnable = bool.fromEnvironment(
      'TELEMETRY_ENABLED',
      defaultValue: false,
    );
    const String env = String.fromEnvironment(
      'TELEMETRY_ENV',
      defaultValue: 'local',
    );
    final bool enabled = forceEnable || kReleaseMode;
    return TelemetryConfig(
      enabled: enabled,
      provider: sentryProvider,
      environment: env,
    );
  }
}
