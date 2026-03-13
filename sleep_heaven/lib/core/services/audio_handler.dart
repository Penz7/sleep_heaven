import 'package:audio_service/audio_service.dart';

/// AudioHandler quản lý notification và lock screen controls.
/// Nhận callback từ controller đang active để điều khiển audio thực tế.
class SleepAudioHandler extends BaseAudioHandler {
  /// Callback được đăng ký bởi controller hiện đang sở hữu notification
  void Function()? onPlayRequested;
  void Function()? onPauseRequested;

  /// Cập nhật metadata hiển thị trên notification/lock screen
  void setNowPlaying({required String id, required String title, required String artist}) {
    mediaItem.add(MediaItem(id: id, title: title, artist: artist));
  }

  /// Cập nhật trạng thái play/pause trên notification
  void setPlaybackState({required bool playing}) {
    playbackState.add(PlaybackState(
      controls: [
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
      ],
      androidCompactActionIndices: const [0],
      processingState: AudioProcessingState.ready,
      playing: playing,
    ));
  }

  @override
  Future<void> play() async => onPlayRequested?.call();

  @override
  Future<void> pause() async => onPauseRequested?.call();

  @override
  Future<void> stop() async {
    onPauseRequested?.call();
    setPlaybackState(playing: false);
  }
}
