import 'dart:async';

import '../catalog/catalog_cache.dart';
import '../catalog/catalog_loader.dart';
import '../models/sound_model.dart';

/// Provider cung cấp danh sách sounds hardcode - 7 free + 14 premium
class LocalSoundProvider {
  static const int startupWarmupLimit = 12;
  static final CatalogLoader _catalogLoader = CatalogLoader();
  static final CatalogCache _catalogCache = CatalogCache();
  static Future<void>? _warmupFuture;

  static void ensureCatalogWarmup() {
    _warmupFuture ??= _tryWarmupCatalog();
  }

  static Future<void> _tryWarmupCatalog() async {
    try {
      final CatalogLoadResult result = await _catalogLoader
          .loadStartupSliceFromAssets(startupLimit: startupWarmupLimit);
      _catalogCache.setSnapshot(version: result.version, sounds: result.sounds);
    } catch (_) {
      // Keep backward-compatible hardcoded fallback if catalog load fails.
    }
  }

  static List<SoundModel> getAllSounds() {
    ensureCatalogWarmup();
    final List<SoundModel>? cached = _catalogCache.snapshot;
    if (cached != null) {
      return cached;
    }
    return _fallbackSounds;
  }

  static List<SoundModel> getStartupSoundsForBudget() {
    final List<SoundModel> all = getAllSounds();
    return all.take(startupWarmupLimit).toList(growable: false);
  }

  static final List<SoundModel> _fallbackSounds = [
    // Rain - 2 free, 3 premium
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
      isPremium: true,
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
      isPremium: true,
      imagePath: 'assets/images/rain/rain_forest.png',
    ),
    // White Noise - 2 free, 3 premium
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
      isPremium: true,
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
    // Music Box - 2 free, 4 premium
    const SoundModel(
      id: 'music_box',
      title: 'Music Box',
      categoryId: 'music_box',
      assetPath: 'assets/sounds/music_box/music_box.mp3',
      isPremium: false,
      imagePath: 'assets/images/music_box/music_box.png',
    ),
    const SoundModel(
      id: 'hair_dryer',
      title: 'Hair Dryer',
      categoryId: 'music_box',
      assetPath: 'assets/sounds/music_box/hair_dryer.mp3',
      isPremium: false,
      imagePath: 'assets/images/music_box/music_box.png',
    ),
    const SoundModel(
      id: 'heartbeat',
      title: 'Heartbeat',
      categoryId: 'music_box',
      assetPath: 'assets/sounds/music_box/heartbeat.mp3',
      isPremium: true,
      imagePath: 'assets/images/music_box/music_box.png',
    ),
    const SoundModel(
      id: 'shushing',
      title: 'Shushing',
      categoryId: 'music_box',
      assetPath: 'assets/sounds/music_box/shushing.mp3',
      isPremium: true,
      imagePath: 'assets/images/music_box/music_box.png',
    ),
    const SoundModel(
      id: 'lullaby_piano',
      title: 'Lullaby Piano',
      categoryId: 'music_box',
      assetPath: 'assets/sounds/music_box/lullaby_piano.mp3',
      isPremium: true,
      imagePath: 'assets/images/music_box/music_box.png',
    ),
    const SoundModel(
      id: 'cliderman',
      title: 'Cliderman',
      categoryId: 'music_box',
      assetPath: 'assets/sounds/music_box/cliderman.mp3',
      isPremium: true,
      imagePath: 'assets/images/music_box/music_box.png',
    ),
    // Nature - 1 free, 4 premium
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
      isPremium: true,
      imagePath: 'assets/images/nature/forest_bird.png',
    ),
    const SoundModel(
      id: 'river_stream',
      title: 'River Stream',
      categoryId: 'nature',
      assetPath: 'assets/sounds/nature/river_stream.mp3',
      isPremium: true,
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
