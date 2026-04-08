import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_heaven/core/errors/domain_error.dart';
import 'package:sleep_heaven/core/observability/telemetry_config.dart';
import 'package:sleep_heaven/core/observability/telemetry_provider.dart';
import 'package:sleep_heaven/core/observability/telemetry_service.dart';
import 'package:sleep_heaven/main.dart';

class _FakeTelemetryProvider implements TelemetryProvider {
  final List<TelemetryEvent> captured = <TelemetryEvent>[];

  @override
  Future<void> capture(TelemetryEvent event) async {
    captured.add(event);
  }
}

void main() {
  test('handled capture reaches telemetry sink', () async {
    final _FakeTelemetryProvider provider = _FakeTelemetryProvider();
    final TelemetryService service = TelemetryService(
      provider: provider,
      config: const TelemetryConfig(enabled: true, provider: 'sentry'),
    );
    await service.capture(
      const DomainError(
        domain: DomainErrorDomain.startup,
        severity: DomainErrorSeverity.recoverable,
        code: 'HANDLED_TEST',
        message: 'handled path',
      ),
    );
    expect(provider.captured, hasLength(1));
    expect(provider.captured.first.tags['code'], equals('HANDLED_TEST'));
  });

  test('framework unhandled capture is routed to telemetry sink', () async {
    final _FakeTelemetryProvider provider = _FakeTelemetryProvider();
    final TelemetryService service = TelemetryService(
      provider: provider,
      config: const TelemetryConfig(enabled: true, provider: 'sentry'),
    );
    configureGlobalErrorHandlers(service);

    FlutterError.onError?.call(
      FlutterErrorDetails(
        exception: Exception('framework boom'),
        stack: StackTrace.current,
      ),
    );

    await Future<void>.delayed(Duration.zero);
    expect(provider.captured, hasLength(1));
    expect(provider.captured.first.tags['domain'], equals('startup'));
  });
}
