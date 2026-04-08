import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_heaven/core/errors/domain_error.dart';
import 'package:sleep_heaven/core/observability/telemetry_config.dart';
import 'package:sleep_heaven/core/observability/telemetry_provider.dart';
import 'package:sleep_heaven/core/observability/telemetry_service.dart';

class _FakeTelemetryProvider implements TelemetryProvider {
  final List<TelemetryEvent> captured = <TelemetryEvent>[];

  @override
  Future<void> capture(TelemetryEvent event) async {
    captured.add(event);
  }
}

void main() {
  group('TelemetryService', () {
    test('captures fatal event with required domain tags', () async {
      final _FakeTelemetryProvider provider = _FakeTelemetryProvider();
      final TelemetryService service = TelemetryService(
        provider: provider,
        config: const TelemetryConfig(
          enabled: true,
          provider: TelemetryConfig.sentryProvider,
        ),
      );
      const DomainError error = DomainError(
        domain: DomainErrorDomain.startup,
        severity: DomainErrorSeverity.fatal,
        code: 'STARTUP_CRASH',
        message: 'Startup crashed.',
      );

      await service.capture(error);

      expect(provider.captured, hasLength(1));
      expect(provider.captured.first.tags['domain'], equals('startup'));
      expect(provider.captured.first.tags['severity'], equals('fatal'));
    });

    test('captures recoverable event with required domain tags', () async {
      final _FakeTelemetryProvider provider = _FakeTelemetryProvider();
      final TelemetryService service = TelemetryService(
        provider: provider,
        config: const TelemetryConfig(
          enabled: true,
          provider: TelemetryConfig.sentryProvider,
        ),
      );
      const DomainError error = DomainError(
        domain: DomainErrorDomain.iap,
        severity: DomainErrorSeverity.recoverable,
        code: 'IAP_RETRY',
        message: 'Retry purchase sync.',
      );

      await service.capture(error);

      expect(provider.captured, hasLength(1));
      expect(provider.captured.first.tags['domain'], equals('iap'));
      expect(provider.captured.first.tags['severity'], equals('recoverable'));
    });

    test('does not emit to provider when telemetry is disabled', () async {
      final _FakeTelemetryProvider provider = _FakeTelemetryProvider();
      final TelemetryService service = TelemetryService(
        provider: provider,
        config: const TelemetryConfig(
          enabled: false,
          provider: TelemetryConfig.sentryProvider,
        ),
      );
      const DomainError error = DomainError(
        domain: DomainErrorDomain.audio,
        severity: DomainErrorSeverity.recoverable,
        code: 'AUDIO_DEGRADED',
        message: 'Audio session degraded.',
      );

      await service.capture(error);

      expect(provider.captured, isEmpty);
      expect(service.localDiagnostics, hasLength(1));
      expect(service.localDiagnostics.first.code, equals('AUDIO_DEGRADED'));
    });
  });
}
