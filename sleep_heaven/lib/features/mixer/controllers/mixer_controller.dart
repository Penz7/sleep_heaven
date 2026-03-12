import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../../data/models/sound_model.dart';
import '../../../data/repositories/sound_repository.dart';
import '../../../routes/app_routes.dart';

class MixerController extends GetxController {
  final SoundRepository _repository = Get.find<SoundRepository>();

  static const int maxTracks = 3;

  final RxMap<String, MixerTrack> tracks = <String, MixerTrack>{}.obs;

  // Observable được cập nhật khi bất kỳ player nào thay đổi trạng thái
  final RxBool isPlayingRx = false.obs;

  // Lưu subscription của từng player để hủy khi remove track
  final Map<String, StreamSubscription<bool>> _playingSubscriptions = {};

  bool get canAddTrack => tracks.length < maxTracks;

  void _updateIsPlaying() {
    isPlayingRx.value = tracks.values.any((t) => t.player.playing);
  }

  Future<void> addTrack(SoundModel sound) async {
    if (sound.isPremium && !_repository.isPremium) {
      Get.toNamed(Routes.premium);
      return;
    }
    if (tracks.containsKey(sound.id)) return;
    if (tracks.length >= maxTracks) return;

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
    ));

    final player = AudioPlayer();
    try {
      await player.setAsset(sound.assetPath);
      await player.setLoopMode(LoopMode.one);
      tracks[sound.id] = MixerTrack(sound: sound, player: player, volume: 0.7.obs);

      // Lắng nghe playingStream để cập nhật isPlayingRx khi state thay đổi
      _playingSubscriptions[sound.id] = player.playingStream.listen((_) {
        _updateIsPlaying();
      });

      // Auto-play track mới nếu mixer đang playing
      if (isPlayingRx.value) {
        player.play();
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not load: $e');
      player.dispose();
    }
  }

  void removeTrack(String soundId) {
    _playingSubscriptions[soundId]?.cancel();
    _playingSubscriptions.remove(soundId);

    final track = tracks[soundId];
    if (track != null) {
      track.player.dispose();
      tracks.remove(soundId);
    }

    _updateIsPlaying();
  }

  Future<void> setTrackVolume(String soundId, double vol) async {
    final track = tracks[soundId];
    if (track != null) {
      track.volume.value = vol.clamp(0.0, 1.0);
      await track.player.setVolume(track.volume.value);
    }
  }

  Future<void> playAll() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
    ));
    for (final track in tracks.values) {
      await track.player.setLoopMode(LoopMode.one);
      track.player.play(); // Không await - play() resolve khi playback kết thúc (loop = vô hạn)
    }
  }

  Future<void> pauseAll() async {
    for (final track in tracks.values) {
      await track.player.pause();
    }
  }

  Future<void> stopAll() async {
    for (final track in tracks.values) {
      await track.player.pause();
      await track.player.seek(Duration.zero);
    }
  }

  @override
  void onClose() {
    for (final sub in _playingSubscriptions.values) {
      sub.cancel();
    }
    _playingSubscriptions.clear();
    for (final track in tracks.values) {
      track.player.dispose();
    }
    tracks.clear();
    super.onClose();
  }
}

class MixerTrack {
  MixerTrack({
    required this.sound,
    required this.player,
    required this.volume,
  });

  final SoundModel sound;
  final AudioPlayer player;
  final RxDouble volume;
}
