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
        assetPath: 'assets/sounds/rain/rain_light.mp3',
        imagePath: 'assets/images/rain/rain_light.png',
        isPremium: false,
      ),  
      const SoundModel(
        id: 'rain_heavy',
        title: 'Heavy Rain',
        categoryId: 'rain',
        assetPath: 'assets/sounds/rain/rain_heavy.mp3',
        imagePath: 'assets/images/rain/rain_heavy.png',
        isPremium: false,
      ),
      const SoundModel(
        id: 'rain_window',
        title: 'Rain on Window',
        categoryId: 'rain',
        assetPath: 'assets/sounds/rain/rain_window.mp3',
        isPremium: false,
        imagePath: 'assets/images/rain/rain_window.png',
      ),
      const SoundModel(
        id: 'thunderstorm',
        title: 'Thunderstorm',
        categoryId: 'rain',
        assetPath: 'assets/sounds/rain/thunderstorm.mp3',
        isPremium: true,
        imagePath: 'assets/images/rain/thunderstorm.png',
      ),
      const SoundModel(
        id: 'rain_forest',
        title: 'Rain Forest',
        categoryId: 'rain',
        assetPath: 'assets/sounds/rain/rain_forest.mp3',
        isPremium: false,
        imagePath: 'assets/images/rain/rain_forest.png',
      ),
      // White Noise - 3 free, 2 premium
      const SoundModel(
        id: 'white_noise',
        title: 'White Noise',
        categoryId: 'white_noise',
        assetPath: 'assets/sounds/white_noise/white_noise.mp3',
        isPremium: false,
        imagePath: 'assets/images/white_noise/white_noise.png',
      ),
      const SoundModel(
        id: 'brown_noise',
        title: 'Brown Noise',
        categoryId: 'white_noise',
        assetPath: 'assets/sounds/white_noise/brown_noise.mp3',
        isPremium: false,
        imagePath: 'assets/images/white_noise/brown_noise.png',
      ),
      const SoundModel(
        id: 'fan',
        title: 'Fan',
        categoryId: 'white_noise',
        assetPath: 'assets/sounds/white_noise/fan.mp3',
        isPremium: false,
        imagePath: 'assets/images/white_noise/fan.png',
      ),
      const SoundModel(
        id: 'pink_noise',
        title: 'Pink Noise',
        categoryId: 'white_noise',
        assetPath: 'assets/sounds/white_noise/pink_noise.mp3',
        isPremium: true,
        imagePath: 'assets/images/white_noise/pink_noise.png',
      ),
      const SoundModel(
        id: 'air_conditioner',
        title: 'Air Conditioner',
        categoryId: 'white_noise',
        assetPath: 'assets/sounds/white_noise/air_conditioner.mp3',
        isPremium: true,
        imagePath: 'assets/images/white_noise/air_conditioner.png',
      ),
      // Baby - 3 free, 2 premium
      const SoundModel(
        id: 'heartbeat',
        title: 'Heartbeat',
        categoryId: 'baby',
        assetPath: 'assets/sounds/baby/heartbeat.mp3',
        isPremium: false,
        imagePath: 'assets/images/baby/baby.png',
      ),
      const SoundModel(
        id: 'shushing',
        title: 'Shushing',
        categoryId: 'baby',
        assetPath: 'assets/sounds/baby/shushing.mp3',
        isPremium: false,
        imagePath: 'assets/images/baby/baby.png',
      ),
      const SoundModel(
        id: 'lullaby_piano',
        title: 'Lullaby Piano',
        categoryId: 'baby',
        assetPath: 'assets/sounds/baby/lullaby_piano.mp3',
        isPremium: false,
        imagePath: 'assets/images/baby/baby.png',
      ),
      const SoundModel(
        id: 'hair_dryer',
        title: 'Hair Dryer',
        categoryId: 'baby',
        assetPath: 'assets/sounds/baby/hair_dryer.mp3',
        isPremium: true,
        imagePath: 'assets/images/baby/baby.png',
      ),
      // Nature - 3 free, 2 premium
      const SoundModel(
        id: 'ocean_waves',
        title: 'Ocean Waves',
        categoryId: 'nature',
        assetPath: 'assets/sounds/nature/ocean_waves.mp3',
        isPremium: false,
        imagePath: 'assets/images/nature/ocean_waves.png',
      ),
      const SoundModel(
        id: 'forest_birds',
        title: 'Forest Birds',
        categoryId: 'nature',
        assetPath: 'assets/sounds/nature/forest_birds.mp3',
        isPremium: false,
        imagePath: 'assets/images/nature/forest_birds.png',
      ),
      const SoundModel(
        id: 'river_stream',
        title: 'River Stream',
        categoryId: 'nature',
        assetPath: 'assets/sounds/nature/river_stream.mp3',
        isPremium: false,
        imagePath: 'assets/images/nature/river_stream.png',
      ),
      const SoundModel(
        id: 'wind_gentle',
        title: 'Gentle Wind',
        categoryId: 'nature',
        assetPath: 'assets/sounds/nature/wind_gentle.mp3',
        isPremium: true,
        imagePath: 'assets/images/nature/wind_gentle.png',
      ),
      const SoundModel(
        id: 'fireplace',
        title: 'Fireplace',
        categoryId: 'nature',
        assetPath: 'assets/sounds/nature/fireplace.mp3',
        isPremium: true,
        imagePath: 'assets/images/nature/fireplace.png',
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
