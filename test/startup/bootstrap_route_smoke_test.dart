@Tags(<String>['critical-smoke'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_heaven/app/bootstrap/degraded_boot_notice.dart';
import 'package:sleep_heaven/core/startup/startup_result.dart';

Widget _buildApp(StartupResult result) {
  if (result.isFatal) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text(result.message ?? 'Startup failed.')),
      ),
    );
  }
  return MaterialApp(
    home: Stack(
      children: <Widget>[
        const Scaffold(body: Text('App Booted')),
        if (result.isDegraded)
          Align(
            alignment: Alignment.topCenter,
            child: DegradedBootNotice(
              message: result.message ?? 'Some services degraded.',
            ),
          ),
      ],
    ),
  );
}

void main() {
  testWidgets(
    'normal boot renders app content',
    (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp(const StartupResult.ok()));
      expect(find.text('App Booted'), findsOneWidget);
      expect(find.byType(DegradedBootNotice), findsNothing);
    },
    timeout: const Timeout(Duration(seconds: 10)),
  );

  testWidgets(
    'degraded boot renders safe notice',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildApp(const StartupResult.degraded('IAP service degraded.')),
      );
      expect(find.text('App Booted'), findsOneWidget);
      expect(find.byType(DegradedBootNotice), findsOneWidget);
      expect(find.text('IAP service degraded.'), findsOneWidget);
    },
    timeout: const Timeout(Duration(seconds: 10)),
  );

  testWidgets(
    'fatal boot blocks normal app content',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildApp(const StartupResult.fatal('Storage bootstrap failed.')),
      );
      expect(find.text('Storage bootstrap failed.'), findsOneWidget);
      expect(find.text('App Booted'), findsNothing);
    },
    timeout: const Timeout(Duration(seconds: 10)),
  );
}
