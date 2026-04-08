import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_heaven/core/errors/domain_error.dart';
import 'package:sleep_heaven/core/observability/telemetry_config.dart';
import 'package:sleep_heaven/core/observability/telemetry_provider.dart';
import 'package:sleep_heaven/core/observability/telemetry_service.dart';
import 'package:sleep_heaven/core/startup/startup_coordinator.dart';

class _FakeTelemetryProvider implements TelemetryProvider {
  final List<TelemetryEvent> events = <TelemetryEvent>[];

  @override
  Future<void> capture(TelemetryEvent event) async {
    events.add(event);
  }
}

void main() {
  group('StartupCoordinator', () {
    test('critical failure returns fatal and blocks boot', () async {
      final _FakeTelemetryProvider provider = _FakeTelemetryProvider();
      final TelemetryService telemetry = TelemetryService(
        provider: provider,
        config: const TelemetryConfig(enabled: true, provider: 'sentry'),
      );
      final StartupCoordinator coordinator = StartupCoordinator(
        telemetryService: telemetry,
        steps: <StartupStepConfig>[
          StartupStepConfig(
            name: 'storage',
            domain: DomainErrorDomain.storage,
            isCritical: true,
            action: () async => throw Exception('storage failed'),
          ),
        ],
      );

      final result = await coordinator.run();

      expect(result.isFatal, isTrue);
      expect(result.isDegraded, isFalse);
      expect(provider.events, hasLength(1));
      expect(provider.events.first.tags['domain'], equals('storage'));
    });

    test('non-critical failure returns degraded and emits telemetry', () async {
      final _FakeTelemetryProvider provider = _FakeTelemetryProvider();
      final TelemetryService telemetry = TelemetryService(
        provider: provider,
        config: const TelemetryConfig(enabled: true, provider: 'sentry'),
      );
      final StartupCoordinator coordinator = StartupCoordinator(
        telemetryService: telemetry,
        steps: <StartupStepConfig>[
          StartupStepConfig(
            name: 'iap',
            domain: DomainErrorDomain.iap,
            isCritical: false,
            action: () async => throw Exception('iap offline'),
          ),
        ],
      );

      final result = await coordinator.run();

      expect(result.isFatal, isFalse);
      expect(result.isDegraded, isTrue);
      expect(provider.events, hasLength(1));
      expect(provider.events.first.tags['domain'], equals('iap'));
    });

    test('startup steps execute in deterministic order', () async {
      final _FakeTelemetryProvider provider = _FakeTelemetryProvider();
      final TelemetryService telemetry = TelemetryService(
        provider: provider,
        config: const TelemetryConfig(enabled: true, provider: 'sentry'),
      );
      final List<String> order = <String>[];
      final StartupCoordinator coordinator = StartupCoordinator(
        telemetryService: telemetry,
        steps: <StartupStepConfig>[
          StartupStepConfig(
            name: 'audio',
            domain: DomainErrorDomain.audio,
            isCritical: true,
            action: () async => order.add('audio'),
          ),
          StartupStepConfig(
            name: 'storage',
            domain: DomainErrorDomain.storage,
            isCritical: true,
            action: () async => order.add('storage'),
          ),
          StartupStepConfig(
            name: 'iap',
            domain: DomainErrorDomain.iap,
            isCritical: false,
            action: () async => order.add('iap'),
          ),
        ],
      );

      final result = await coordinator.run();

      expect(result.isFatal, isFalse);
      expect(result.isDegraded, isFalse);
      expect(order, equals(<String>['audio', 'storage', 'iap']));
    });
  });
}
