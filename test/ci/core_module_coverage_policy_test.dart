import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../../tool/coverage/core_module_coverage_check.dart' as coverage_tool;

String _joinPath(String left, String right) {
  final String separator = Platform.pathSeparator;
  if (left.endsWith(separator)) {
    return '$left$right';
  }
  return '$left$separator$right';
}

void main() {
  group('core coverage policy', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('coverage_policy_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('fails when core module coverage is below threshold', () async {
      final File lcov = File(_joinPath(tempDir.path, 'lcov.info'));
      lcov.writeAsStringSync('''
SF:lib/core/services/critical_service.dart
DA:1,0
DA:2,0
DA:3,1
end_of_record
''');
      final File baseline = File(_joinPath(tempDir.path, 'baseline.json'));
      baseline.writeAsStringSync(
        jsonEncode(<String, Object>{'minimum_core_coverage_percent': 80}),
      );

      final List<String> errors = <String>[];
      final int result = coverage_tool.runCoverageGate(<String>[
        '--lcov',
        lcov.path,
        '--baseline-file',
        baseline.path,
      ], errorLog: errors.add);

      expect(result, isNonZero);
      expect(errors.join('\n'), contains('Core coverage gate failed'));
    });

    test(
      'non-core coverage is advisory and does not block when core passes',
      () async {
        final File lcov = File(_joinPath(tempDir.path, 'lcov.info'));
        lcov.writeAsStringSync('''
SF:lib/core/startup/boot.dart
DA:1,1
DA:2,1
end_of_record
SF:lib/app/non_core.dart
DA:1,0
DA:2,0
end_of_record
''');
        final File baseline = File(_joinPath(tempDir.path, 'baseline.json'));
        baseline.writeAsStringSync(
          jsonEncode(<String, Object>{'minimum_core_coverage_percent': 80}),
        );

        final int result = coverage_tool.runCoverageGate(<String>[
          '--lcov',
          lcov.path,
          '--baseline-file',
          baseline.path,
          '--summary-out',
          _joinPath(tempDir.path, 'summary.json'),
        ]);

        expect(result, equals(0));
        final File summary = File(_joinPath(tempDir.path, 'summary.json'));
        final Map<String, dynamic> data =
            jsonDecode(summary.readAsStringSync()) as Map<String, dynamic>;
        expect(data['non_core_advisory']['blocking'], isFalse);
      },
    );

    test(
      'ratchet eligibility is true only at or above ratchet threshold',
      () async {
        final File lcov = File(_joinPath(tempDir.path, 'lcov.info'));
        lcov.writeAsStringSync('''
SF:lib/core/services/critical_service.dart
DA:1,1
DA:2,1
DA:3,1
DA:4,0
end_of_record
''');
        final File baseline = File(_joinPath(tempDir.path, 'baseline.json'));
        baseline.writeAsStringSync(
          jsonEncode(<String, Object>{
            'minimum_core_coverage_percent': 70,
            'ratchet_threshold_percent': 75,
          }),
        );

        final int result = coverage_tool.runCoverageGate(<String>[
          '--lcov',
          lcov.path,
          '--baseline-file',
          baseline.path,
          '--summary-out',
          _joinPath(tempDir.path, 'summary.json'),
        ]);

        expect(result, equals(0));
        final File summary = File(_joinPath(tempDir.path, 'summary.json'));
        final Map<String, dynamic> data =
            jsonDecode(summary.readAsStringSync()) as Map<String, dynamic>;
        expect(data['core']['ratchet_eligible'], isTrue);
      },
    );
  });
}
