enum DomainErrorDomain { startup, iap, audio, storage, permission }

enum DomainErrorSeverity { fatal, recoverable }

class DomainError {
  const DomainError({
    required this.domain,
    required this.severity,
    required this.code,
    required this.message,
    this.cause,
    this.stackTrace,
  });

  final DomainErrorDomain domain;
  final DomainErrorSeverity severity;
  final String code;
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  Map<String, String> toSafeTags() {
    return <String, String>{
      'domain': domain.name,
      'severity': severity.name,
      'code': code,
    };
  }
}
