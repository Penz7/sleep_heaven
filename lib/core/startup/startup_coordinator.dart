import '../errors/domain_error.dart';
import '../observability/telemetry_service.dart';
import 'startup_result.dart';

typedef StartupStep = Future<void> Function();

class StartupStepConfig {
  const StartupStepConfig({
    required this.name,
    required this.domain,
    required this.isCritical,
    required this.action,
  });

  final String name;
  final DomainErrorDomain domain;
  final bool isCritical;
  final StartupStep action;
}

class StartupCoordinator {
  const StartupCoordinator({
    required TelemetryService telemetryService,
    required List<StartupStepConfig> steps,
  }) : _telemetryService = telemetryService,
       _steps = steps;

  final TelemetryService _telemetryService;
  final List<StartupStepConfig> _steps;

  Future<StartupResult> run() async {
    for (final StartupStepConfig step in _steps) {
      try {
        await step.action();
      } catch (error, stackTrace) {
        final DomainError domainError = DomainError(
          domain: step.domain,
          severity: step.isCritical
              ? DomainErrorSeverity.fatal
              : DomainErrorSeverity.recoverable,
          code: 'STARTUP_${step.name.toUpperCase()}',
          message: step.isCritical
              ? 'Critical startup step failed.'
              : 'Non-critical startup step failed.',
          cause: error,
          stackTrace: stackTrace,
        );
        await _telemetryService.capture(domainError);
        if (step.isCritical) {
          return StartupResult.fatal('Startup failed at ${step.name}.');
        }
        return StartupResult.degraded(
          'Some services are degraded: ${step.name}.',
        );
      }
    }
    return const StartupResult.ok();
  }
}
