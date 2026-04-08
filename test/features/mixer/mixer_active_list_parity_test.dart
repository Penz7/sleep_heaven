import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import 'package:sleep_heaven/features/mixer/views/widgets/active_sounds_header.dart';
import 'package:sleep_heaven/features/mixer/views/widgets/mixer_track_card.dart';

class _FakeTrack {
  _FakeTrack({
    required this.title,
    required this.categoryId,
    required this.volume,
  });

  final String title;
  final String categoryId;
  final RxDouble volume;
}

void main() {
  testWidgets('active header shows label and playing count parity', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ActiveSoundsHeader(playingCount: 2)),
      ),
    );

    expect(find.text('ACTIVE SOUNDS'), findsOneWidget);
    expect(find.text('2 playing'), findsOneWidget);
  });

  testWidgets('track card keeps control parity and emits callbacks', (
    WidgetTester tester,
  ) async {
    final _FakeTrack track = _FakeTrack(
      title: 'Rain',
      categoryId: 'rain',
      volume: 0.5.obs,
    );

    bool removed = false;
    double? changedVolume;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MixerTrackCard(
            soundId: 'rain_light',
            track: track,
            onRemove: () => removed = true,
            onVolumeChanged: (double value) {
              changedVolume = value;
            },
            glassBuilder:
                ({
                  required Widget child,
                  EdgeInsetsGeometry? padding,
                  double borderRadius = 16,
                }) {
                  return Container(
                    padding: padding,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    child: child,
                  );
                },
          ),
        ),
      ),
    );

    expect(find.text('Rain'), findsOneWidget);
    expect(find.text('rain'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('rain_light')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(removed, isTrue);

    await tester.drag(find.byType(Slider), const Offset(32, 0));
    await tester.pump();
    expect(changedVolume, isNotNull);
  });
}
