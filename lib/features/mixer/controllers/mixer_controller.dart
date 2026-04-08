import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/services/audio_handler.dart';
import '../../../data/models/local_track_model.dart';
import '../../../data/models/sound_model.dart';
import '../../../data/repositories/sound_repository.dart';
import '../../../routes/app_routes.dart';

class MixerController extends GetxController {
  static const String _ownerId = 'mixer_controller';
  final SoundRepository _repository = Get.find<SoundRepository>();
  late final SleepAudioHandler _handler;

  /// Premium: 5 tracks, Free: 3 tracks
  int get maxTracks => _repository.isPremium ? 5 : 3;

  final RxMap<String, MixerTrack> tracks = <String, MixerTrack>{}.obs;

  // Observable được cập nhật khi bất kỳ player nào thay đổi trạng thái
  final RxBool isPlayingRx = false.obs;

  // Lưu subscription của từng player để hủy khi remove track
  final Map<String, StreamSubscription<bool>> _playingSubscriptions = {};

  bool get canAddTrack => tracks.length < maxTracks;
  int? _ownershipToken;

  @override
  void onInit() {
    super.onInit();
    _handler = Get.find<SleepAudioHandler>();
  }

  void _updateIsPlaying() {
    final playing = tracks.values.any((t) => t.player.playing);
    isPlayingRx.value = playing;
    // Mixer không có timeline nên position = zero; iOS vẫn hiển thị trạng thái play/pause đúng
    _handler.setPlaybackState(playing: playing, position: Duration.zero);
  }

  Future<void> addTrack(SoundModel sound) async {
    if (sound.isPremium && !_repository.isPremium) {
      Get.toNamed(Routes.premium);
      return;
    }
    if (tracks.containsKey(sound.id)) return;
    if (tracks.length >= maxTracks) return;

    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
      ),
    );

    final player = AudioPlayer();
    try {
      await player.setAsset(sound.assetPath);
      await player.setLoopMode(LoopMode.one);
      tracks[sound.id] = MixerTrack(
        sound: sound,
        localTrack: null,
        player: player,
        volume: 0.7.obs,
      );

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

  /// Thêm track từ file local (premium only – gọi từ UI đã check)
  Future<void> addLocalTrack(LocalTrackModel localTrack) async {
    final trackId = localTrack.id;
    if (tracks.containsKey(trackId)) return;
    if (tracks.length >= maxTracks) return;

    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
      ),
    );

    final player = AudioPlayer();
    try {
      await player.setFilePath(localTrack.filePath);
      await player.setLoopMode(LoopMode.one);
      tracks[trackId] = MixerTrack(
        sound: null,
        localTrack: localTrack,
        player: player,
        volume: 0.7.obs,
      );

      _playingSubscriptions[trackId] = player.playingStream.listen((_) {
        _updateIsPlaying();
      });

      if (isPlayingRx.value) {
        player.play();
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not load file: $e');
      player.dispose();
    }
  }

  Future<void> removeTrack(String soundId) async {
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
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
      ),
    );
    // Đăng ký mixer làm chủ notification khi bắt đầu phát
    _ownershipToken = _handler.acquireOwnership(
      ownerId: _ownerId,
      onPlayRequested: _playAllFromRemote,
      onPauseRequested: _pauseAllFromRemote,
    );
    _handler.setNowPlaying(
      id: 'mixer',
      title: 'Sleep Heaven - Mixer',
      artist: 'Sleep Heaven',
    );
    for (final track in tracks.values) {
      await track.player.setLoopMode(LoopMode.one);
      track.player
          .play(); // Không await - play() resolve khi playback kết thúc (loop = vô hạn)
    }
  }

  Future<void> pauseAll() async {
    for (final track in tracks.values) {
      await track.player.pause();
    }
  }

  void _playAllFromRemote() {
    playAll();
  }

  void _pauseAllFromRemote() {
    pauseAll();
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
    _releaseOwnership();
    super.onClose();
  }

  void _releaseOwnership() {
    final int? token = _ownershipToken;
    if (token == null) {
      return;
    }
    _handler.releaseOwnership(ownerId: _ownerId, token: token);
    _ownershipToken = null;
  }
}

class MixerTrack {
  MixerTrack({
    this.sound,
    this.localTrack,
    required this.player,
    required this.volume,
  }) : assert(sound != null || localTrack != null);

  final SoundModel? sound;
  final LocalTrackModel? localTrack;
  final AudioPlayer player;
  final RxDouble volume;

  String get title => sound?.title ?? localTrack!.title;
  String get categoryId => sound?.categoryId ?? 'local';
}
