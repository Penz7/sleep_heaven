import '../models/sound_model.dart';

/// Provider cung cấp danh sách sounds hardcode - 12 free + 8 premium
class LocalSoundProvider {
  static List<SoundModel> getAllSounds() {
    return [
      // Rain - 3 free, 2 premium
      const SoundModel(
        id: 'rain_light',
        title: 'Light Rain',
        categoryId: 'rain',
        assetPath: 'assets/sounds/rain/rain_light.ogg',
        isPremium: false,
      ),
      const SoundModel(
        id: 'rain_heavy',
        title: 'Heavy Rain',
        categoryId: 'rain',
        assetPath: 'assets/sounds/rain/rain_heavy.ogg',
        isPremium: false,
      ),
      const SoundModel(
        id: 'rain_window',
        title: 'Rain on Window',
        categoryId: 'rain',
        assetPath: 'assets/sounds/rain/rain_window.ogg',
        isPremium: false,
      ),
      const SoundModel(
        id: 'thunderstorm',
        title: 'Thunderstorm',
        categoryId: 'rain',
        assetPath: 'assets/sounds/rain/thunderstorm.ogg',
        isPremium: true,
      ),
      const SoundModel(
        id: 'rain_forest',
        title: 'Rain Forest',
        categoryId: 'rain',
        assetPath: 'assets/sounds/rain/rain_forest.ogg',
        isPremium: false,
      ),
      // White Noise - 3 free, 2 premium
      const SoundModel(
        id: 'white_noise',
        title: 'White Noise',
        categoryId: 'white_noise',
        assetPath: 'assets/sounds/white_noise/white_noise.ogg',
        isPremium: false,
      ),
      const SoundModel(
        id: 'brown_noise',
        title: 'Brown Noise',
        categoryId: 'white_noise',
        assetPath: 'assets/sounds/white_noise/brown_noise.ogg',
        isPremium: false,
      ),
      const SoundModel(
        id: 'fan',
        title: 'Fan',
        categoryId: 'white_noise',
        assetPath: 'assets/sounds/white_noise/fan.ogg',
        isPremium: false,
      ),
      const SoundModel(
        id: 'pink_noise',
        title: 'Pink Noise',
        categoryId: 'white_noise',
        assetPath: 'assets/sounds/white_noise/pink_noise.ogg',
        isPremium: true,
      ),
      const SoundModel(
        id: 'air_conditioner',
        title: 'Air Conditioner',
        categoryId: 'white_noise',
        assetPath: 'assets/sounds/white_noise/air_conditioner.ogg',
        isPremium: true,
      ),
      // Baby - 3 free, 2 premium
      const SoundModel(
        id: 'heartbeat',
        title: 'Heartbeat',
        categoryId: 'baby',
        assetPath: 'assets/sounds/baby/heartbeat.ogg',
        isPremium: false,
      ),
      const SoundModel(
        id: 'shushing',
        title: 'Shushing',
        categoryId: 'baby',
        assetPath: 'assets/sounds/baby/shushing.ogg',
        isPremium: false,
      ),
      const SoundModel(
        id: 'lullaby_piano',
        title: 'Lullaby Piano',
        categoryId: 'baby',
        assetPath: 'assets/sounds/baby/lullaby_piano.ogg',
        isPremium: false,
      ),
      const SoundModel(
        id: 'hair_dryer',
        title: 'Hair Dryer',
        categoryId: 'baby',
        assetPath: 'assets/sounds/baby/hair_dryer.ogg',
        isPremium: true,
      ),
      // Nature - 3 free, 2 premium
      const SoundModel(
        id: 'ocean_waves',
        title: 'Ocean Waves',
        categoryId: 'nature',
        assetPath: 'assets/sounds/nature/ocean_waves.ogg',
        isPremium: false,
      ),
      const SoundModel(
        id: 'forest_birds',
        title: 'Forest Birds',
        categoryId: 'nature',
        assetPath: 'assets/sounds/nature/forest_birds.ogg',
        isPremium: false,
      ),
      const SoundModel(
        id: 'river_stream',
        title: 'River Stream',
        categoryId: 'nature',
        assetPath: 'assets/sounds/nature/river_stream.ogg',
        isPremium: false,
      ),
      const SoundModel(
        id: 'wind_gentle',
        title: 'Gentle Wind',
        categoryId: 'nature',
        assetPath: 'assets/sounds/nature/wind_gentle.ogg',
        isPremium: true,
      ),
      const SoundModel(
        id: 'fireplace',
        title: 'Fireplace',
        categoryId: 'nature',
        assetPath: 'assets/sounds/nature/fireplace.ogg',
        isPremium: true,
      ),
    ];
  }

  static List<SoundModel> getSoundsByCategory(String categoryId) {
    return getAllSounds().where((s) => s.categoryId == categoryId).toList();
  }

  static SoundModel? getSoundById(String id) {
    try {
      return getAllSounds().firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
