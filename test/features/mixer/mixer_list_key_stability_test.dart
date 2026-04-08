import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

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

Widget _buildList(List<String> ids) {
  return MaterialApp(
    home: Scaffold(
      body: ListView.builder(
        itemCount: ids.length,
        itemBuilder: (BuildContext context, int index) {
          final String id = ids[index];
          return MixerTrackCard(
            soundId: id,
            track: _FakeTrack(title: id, categoryId: 'rain', volume: 0.5.obs),
            onRemove: () {},
            onVolumeChanged: (_) {},
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
          );
        },
      ),
    ),
  );
}

void main() {
  testWidgets('row identity remains stable across reorder by soundId key', (
    WidgetTester tester,
  ) async {
    final List<String> original = <String>['sound_a', 'sound_b', 'sound_c'];
    await tester.pumpWidget(_buildList(original));
    await tester.pumpAndSettle();

    final Finder targetFinder = find.byKey(const ValueKey<String>('sound_b'));
    final Element before = tester.element(targetFinder);

    final List<String> reordered = <String>['sound_c', 'sound_b', 'sound_a'];
    await tester.pumpWidget(_buildList(reordered));
    await tester.pumpAndSettle();

    final Element after = tester.element(targetFinder);
    expect(identical(before, after), isTrue);
    expect(find.byKey(const ValueKey<String>('sound_a')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('sound_b')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('sound_c')), findsOneWidget);
  });
}
