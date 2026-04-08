import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mixer view composes section modules with stable shell wiring', () {
    final String source = File(
      'lib/features/mixer/views/mixer_view.dart',
    ).readAsStringSync();

    expect(source.contains('MixerHeaderSection'), isTrue);
    expect(source.contains('ActiveSoundsSection'), isTrue);
    expect(source.contains('MixerBottomSection'), isTrue);
    expect(source.contains('class _MixerHeader'), isFalse);
    expect(source.contains('class _MixerBottomArea'), isFalse);
  });
}
