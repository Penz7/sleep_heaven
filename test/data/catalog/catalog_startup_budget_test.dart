import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_heaven/data/providers/local_sound_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('provider startup warmup path stays within bounded budget', () {
    final List sounds = LocalSoundProvider.getStartupSoundsForBudget();
    expect(sounds.length, lessThanOrEqualTo(LocalSoundProvider.startupWarmupLimit));
    expect(sounds, isNotEmpty);
  });
}
