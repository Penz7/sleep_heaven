import '../models/sound_model.dart';
import '../providers/hive_provider.dart';
import '../providers/local_sound_provider.dart';

/// Repository interface & implementation - quản lý sounds và favorites
class SoundRepository {
  SoundRepository(this._hiveProvider);

  final HiveProvider _hiveProvider;

  List<SoundModel> getAllSounds() => LocalSoundProvider.getAllSounds();

  List<SoundModel> getSoundsByCategory(String categoryId) =>
      LocalSoundProvider.getSoundsByCategory(categoryId);

  SoundModel? getSoundById(String id) => LocalSoundProvider.getSoundById(id);

  List<SoundModel> getFavorites() {
    final ids = _hiveProvider.favoriteIds;
    return ids
        .map((id) => LocalSoundProvider.getSoundById(id))
        .whereType<SoundModel>()
        .toList();
  }

  void toggleFavorite(String soundId) => _hiveProvider.toggleFavorite(soundId);

  bool isFavorite(String soundId) => _hiveProvider.isFavorite(soundId);

  bool get isPremium => _hiveProvider.isPremium;
}
