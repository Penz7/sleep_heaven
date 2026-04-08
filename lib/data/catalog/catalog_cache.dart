import '../models/sound_model.dart';

class CatalogCache {
  String? _version;
  List<SoundModel>? _sounds;

  String? get version => _version;

  List<SoundModel>? get snapshot => _sounds;

  bool get hasSnapshot => _sounds != null;

  void setSnapshot({required String version, required List<SoundModel> sounds}) {
    _version = version;
    _sounds = List<SoundModel>.unmodifiable(sounds);
  }
}
