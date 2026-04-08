class StartupResult {
  const StartupResult._({
    required this.isFatal,
    required this.isDegraded,
    this.message,
  });

  const StartupResult.ok() : this._(isFatal: false, isDegraded: false);

  const StartupResult.degraded(String msg)
    : this._(isFatal: false, isDegraded: true, message: msg);

  const StartupResult.fatal(String msg)
    : this._(isFatal: true, isDegraded: false, message: msg);

  final bool isFatal;
  final bool isDegraded;
  final String? message;
}
