import 'dart:convert';
import 'dart:io';

const List<String> _corePathPrefixes = <String>[
  'lib/core/services/',
  'lib/core/startup/',
  'lib/features/',
  'lib/data/providers/',
  'lib/data/repositories/',
];

final RegExp _featuresControllerPattern =
    RegExp(r'^lib/features/.+/controllers/');

class _CoverageStats {
  const _CoverageStats({required this.total, required this.hit});

  final int total;
  final int hit;

  double get percent => total == 0 ? 0 : (hit / total) * 100;
}

void main(List<String> args) {
  exitCode = runCoverageGate(args);
}

int runCoverageGate(
  List<String> args, {
  void Function(String message)? infoLog,
  void Function(String message)? errorLog,
}) {
  final void Function(String message) info = infoLog ?? stdout.writeln;
  final void Function(String message) error = errorLog ?? stderr.writeln;

  final Map<String, String> cli = _parseArgs(args);
  final String lcovPath = cli['lcov'] ?? 'coverage/lcov.info';
  final String baselinePath = cli['baseline-file'] ?? '';
  final String summaryPath = cli['summary-out'] ?? 'coverage/core-coverage-summary.json';

  final Map<String, dynamic> baseline = _readBaseline(baselinePath);
  final double minThreshold =
      (baseline['minimum_core_coverage_percent'] as num?)?.toDouble() ?? 0;
  final double ratchetThreshold =
      (baseline['ratchet_threshold_percent'] as num?)?.toDouble() ?? minThreshold;

  final _CoverageStats core = _computeCoverage(
    lcovPath: lcovPath,
    includePath: _isCorePath,
  );
  final _CoverageStats advisory = _computeCoverage(
    lcovPath: lcovPath,
    includePath: (String path) => !_isCorePath(path),
  );

  final bool coreGatePass = core.percent >= minThreshold;
  final bool ratchetEligible = core.percent >= ratchetThreshold;
  final Map<String, dynamic> summary = <String, dynamic>{
    'core': <String, dynamic>{
      'threshold': minThreshold,
      'ratchet_threshold': ratchetThreshold,
      'covered_lines': core.hit,
      'total_lines': core.total,
      'coverage_percent': _round2(core.percent),
      'pass': coreGatePass,
      'ratchet_eligible': ratchetEligible,
    },
    'non_core_advisory': <String, dynamic>{
      'covered_lines': advisory.hit,
      'total_lines': advisory.total,
      'coverage_percent': _round2(advisory.percent),
      'blocking': false,
    },
  };

  final File summaryFile = File(summaryPath);
  summaryFile.parent.createSync(recursive: true);
  summaryFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(summary),
  );

  info('Core coverage: ${_round2(core.percent)}% (threshold: $minThreshold%)');
  info('Non-core advisory coverage: ${_round2(advisory.percent)}%');
  info('Summary: ${summaryFile.path}');
  if (!coreGatePass) {
    error(
      'Core coverage gate failed (${_round2(core.percent)}% < $minThreshold%).',
    );
    return 1;
  }
  return 0;
}

_CoverageStats _computeCoverage({
  required String lcovPath,
  required bool Function(String path) includePath,
}) {
  final File lcov = File(lcovPath);
  if (!lcov.existsSync()) {
    throw ArgumentError('LCOV file not found: $lcovPath');
  }

  String currentFile = '';
  int total = 0;
  int hit = 0;
  for (final String line in lcov.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3).replaceAll('\\', '/');
      continue;
    }
    if (!line.startsWith('DA:') || !includePath(currentFile)) {
      continue;
    }
    final List<String> parts = line.substring(3).split(',');
    if (parts.length < 2) {
      continue;
    }
    total += 1;
    final int hits = int.tryParse(parts[1]) ?? 0;
    if (hits > 0) {
      hit += 1;
    }
  }
  return _CoverageStats(total: total, hit: hit);
}

bool _isCorePath(String path) {
  final String normalized = path.replaceAll('\\', '/');
  if (_featuresControllerPattern.hasMatch(normalized)) {
    return true;
  }
  return _corePathPrefixes.any(normalized.startsWith);
}

Map<String, dynamic> _readBaseline(String path) {
  if (path.isEmpty) {
    return <String, dynamic>{};
  }
  final File file = File(path);
  if (!file.existsSync()) {
    return <String, dynamic>{};
  }
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

Map<String, String> _parseArgs(List<String> args) {
  final Map<String, String> parsed = <String, String>{};
  for (int i = 0; i < args.length; i += 1) {
    final String arg = args[i];
    if (!arg.startsWith('--') || i + 1 >= args.length) {
      continue;
    }
    parsed[arg.substring(2)] = args[i + 1];
    i += 1;
  }
  return parsed;
}

double _round2(double value) => (value * 100).roundToDouble() / 100;
