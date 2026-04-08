import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sleep_heaven/features/mixer/views/mixer_perf_tier.dart';
import 'package:sleep_heaven/features/mixer/views/widgets/glass_container.dart';

void main() {
  test('capable evidence resolves to capable tier', () {
    const MixerPerfEvidence evidence = MixerPerfEvidence(
      p95UiFrameMs: 7.5,
      p95RasterFrameMs: 7.8,
      jankRatio: 0.01,
    );

    expect(MixerPerfTierPolicy.resolve(evidence), MixerPerfTier.capable);
  });

  test('constrained evidence resolves to constrained tier', () {
    const MixerPerfEvidence evidence = MixerPerfEvidence(
      p95UiFrameMs: 15.1,
      p95RasterFrameMs: 14.0,
      jankRatio: 0.05,
    );

    expect(MixerPerfTierPolicy.resolve(evidence), MixerPerfTier.constrained);
  });

  testWidgets('glass container renders child for both tiers', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: <Widget>[
              GlassContainer(
                tier: MixerPerfTier.capable,
                child: Text('capable'),
              ),
              GlassContainer(
                tier: MixerPerfTier.constrained,
                child: Text('constrained'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('capable'), findsOneWidget);
    expect(find.text('constrained'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNWidgets(2));
  });
}
