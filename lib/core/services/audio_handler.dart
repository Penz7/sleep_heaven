import 'package:audio_service/audio_service.dart';

/// AudioHandler quản lý notification và lock screen controls.
/// Nhận callback từ controller đang active để điều khiển audio thực tế.
class SleepAudioHandler extends BaseAudioHandler {
  /// Callback được đăng ký bởi controller hiện đang sở hữu notification
  void Function()? onPlayRequested;
  void Function()? onPauseRequested;

  String? _originalArtist;

  /// Cập nhật metadata hiển thị trên notification/lock screen.
  /// [duration] cần thiết để iOS hiển thị thanh tiến trình trên Lock Screen / Control Center.
  void setNowPlaying({
    required String id,
    required String title,
    required String artist,
    Duration? duration,
  }) {
    _originalArtist = artist;
    mediaItem.add(MediaItem(id: id, title: title, artist: artist, duration: duration));
  }

  /// Cập nhật trạng thái play/pause trên notification.
  /// [position] cần thiết để iOS biết vị trí phát hiện tại — iOS sẽ tự tính toán
  /// thời gian trôi qua dựa trên position + updateTime mà không cần update mỗi giây.
  void setPlaybackState({required bool playing, Duration position = Duration.zero}) {
    playbackState.add(PlaybackState(
      controls: [
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
      ],
      androidCompactActionIndices: const [0],
      processingState: AudioProcessingState.ready,
      playing: playing,
      updatePosition: position,
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

  /// Đặt duration của MediaItem thành timer duration để progress bar trên lock screen
  /// hiển thị tiến trình sleep timer thay vì audio file (thường chỉ vài chục giây).
  void setTimerDuration(Duration timerDuration) {
    final current = mediaItem.value;
    if (current == null) return;
    mediaItem.add(current.copyWith(duration: timerDuration));
  }

  /// Xóa timer và khôi phục trạng thái ban đầu: artist gốc + audio file duration.
  /// Gọi khi timer kết thúc hoặc user tắt timer.
  void clearTimer(Duration? audioDuration) {
    final current = mediaItem.value;
    if (current == null) return;
    mediaItem.add(current.copyWith(
      artist: _originalArtist ?? 'Sleep Heaven',
      duration: audioDuration,
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
