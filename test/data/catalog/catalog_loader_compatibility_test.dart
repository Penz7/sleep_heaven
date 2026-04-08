import 'package:flutter_test/flutter_test.dart';

import 'package:sleep_heaven/data/providers/local_sound_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('required IDs and categories remain available', () {
    final sounds = LocalSoundProvider.getAllSounds();
    final ids = sounds.map((s) => s.id).toSet();
    final categories = sounds.map((s) => s.categoryId).toSet();

    expect(ids.contains('rain_light'), isTrue);
    expect(ids.contains('white_noise'), isTrue);
    expect(ids.contains('music_box'), isTrue);
    expect(ids.contains('ocean_waves'), isTrue);

    expect(categories.contains('rain'), isTrue);
    expect(categories.contains('white_noise'), isTrue);
    expect(categories.contains('music_box'), isTrue);
    expect(categories.contains('nature'), isTrue);
  });

  test('provider compatibility APIs still return sound lookups', () {
    final all = LocalSoundProvider.getAllSounds();
    final byCategory = LocalSoundProvider.getSoundsByCategory('rain');
    final byId = LocalSoundProvider.getSoundById('rain_light');

    expect(all, isNotEmpty);
    expect(byCategory, isNotEmpty);
    expect(byId, isNotNull);
    expect(byId!.categoryId, 'rain');
  });
}
