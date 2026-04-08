import '../errors/domain_error.dart';
import 'telemetry_config.dart';
import 'telemetry_provider.dart';

class TelemetryService {
  TelemetryService({
    required TelemetryProvider provider,
    required TelemetryConfig config,
  }) : _provider = provider,
       _config = config;

  final TelemetryProvider _provider;
  final TelemetryConfig _config;
  final List<DomainError> _localDiagnostics = <DomainError>[];

  List<DomainError> get localDiagnostics =>
      List<DomainError>.unmodifiable(_localDiagnostics);

  Future<void> capture(DomainError error) async {
    _localDiagnostics.add(error);
    if (!_config.enabled) {
      return;
    }
    final TelemetryEvent event = TelemetryEvent(
      error: error,
      tags: error.toSafeTags(),
      level: error.severity.name,
    );
    await _provider.capture(event);
  }
}
