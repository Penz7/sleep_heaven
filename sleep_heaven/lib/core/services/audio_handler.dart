import 'package:audio_service/audio_service.dart';

/// AudioHandler quản lý notification và lock screen controls.
/// Nhận callback từ controller đang active để điều khiển audio thực tế.
class SleepAudioHandler extends BaseAudioHandler {
  /// Callback được đăng ký bởi controller hiện đang sở hữu notification
  void Function()? onPlayRequested;
  void Function()? onPauseRequested;

  String? _originalArtist;

  /// Cập nhật metadata hiển thị trên notification/lock screen
  void setNowPlaying({required String id, required String title, required String artist}) {
    _originalArtist = artist;
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

  /// Cập nhật notification hiển thị thời gian còn lại (gọi mỗi giây khi timer chạy)
  void updateTimerNotification(Duration remaining) {
    final current = mediaItem.value;
    if (current == null) return;
    // Dùng artist field - hiển thị đáng tin cậy trên cả Android notification và iOS lock screen
    mediaItem.add(current.copyWith(
      artist: '⏱ ${_formatRemaining(remaining)} remaining',
    ));
  }

  /// Xóa timer khỏi notification (khi Off hoặc timer kết thúc)
  void clearTimerNotification() {
    final current = mediaItem.value;
    if (current == null) return;
    mediaItem.add(current.copyWith(artist: _originalArtist ?? 'Sleep Heaven'));
  }

  String _formatRemaining(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
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
