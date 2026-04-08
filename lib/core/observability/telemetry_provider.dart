import 'package:sentry_flutter/sentry_flutter.dart';

import '../errors/domain_error.dart';

class TelemetryEvent {
  const TelemetryEvent({
    required this.error,
    required this.tags,
    required this.level,
  });

  final DomainError error;
  final Map<String, String> tags;
  final String level;
}

abstract class TelemetryProvider {
  Future<void> capture(TelemetryEvent event);
}

class SentryTelemetryProvider implements TelemetryProvider {
  const SentryTelemetryProvider();

  @override
  Future<void> capture(TelemetryEvent event) async {
    await Sentry.captureException(
      event.error.cause ?? Exception(event.error.message),
      stackTrace: event.error.stackTrace,
      withScope: (Scope scope) {
        scope.setTag('domain', event.tags['domain'] ?? 'unknown');
        scope.setTag('severity', event.tags['severity'] ?? 'unknown');
        scope.setTag('code', event.tags['code'] ?? 'unknown');
        scope.level = event.level == DomainErrorSeverity.fatal.name
            ? SentryLevel.fatal
            : SentryLevel.error;
      },
    );
  }
}
