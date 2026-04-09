import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/services/audio_handler.dart';
import '../../../core/utils/audio_helpers.dart';
import '../../../data/models/sound_model.dart';
import '../../../data/repositories/sound_repository.dart';
import '../../../routes/app_routes.dart';

class PlayerController extends GetxController with WidgetsBindingObserver {
  static const String _ownerId = 'player_controller';
  final SoundRepository _repository = Get.find<SoundRepository>();
  late final SleepAudioHandler _handler;

  final AudioPlayer _player = AudioPlayer();

  final Rx<SoundModel?> currentSound = Rx<SoundModel?>(null);
  final RxBool isPlaying = false.obs;
  final RxBool hasActiveSession = false.obs;
  final RxDouble volume = 1.0.obs;
  final RxInt timerMinutes = 0.obs;
  final Rx<Duration> remainingTime = Duration.zero.obs;

  // Wall-clock stop time thay vì đếm giây — đảm bảo hoạt động ngay cả khi
  // iOS throttle Dart Timer trong background/lock screen.
  DateTime? _scheduledStopAt;
  Timer? _timerCountdown;
  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<double>? _volumeSubscription;

  AudioPlayer get player => _player;
  int? _ownershipToken;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _handler = Get.find<SleepAudioHandler>();
    _initAudioSession();
    _listenToPlayer();
    final args = Get.arguments;
    if (args is SoundModel) {
      loadSound(args);
    }
  }

  void syncRouteArguments(Object? args) {
    if (args is! SoundModel) {
      return;
    }
    if (currentSound.value?.id == args.id) {
      return;
    }
    stop().then((_) => loadSound(args));
  }

  /// Kiểm tra khi app resume từ background: nếu timer đã hết trong lúc background thì dừng ngay
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final stopAt = _scheduledStopAt;
      if (stopAt != null && isPlaying.value && DateTime.now().isAfter(stopAt)) {
        _cancelTimers();
        _fadeOutAndStop();
      }
    }
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    // Không dùng mixWithOthers: app sẽ lấy audio focus độc quyền,
    // giúp iOS nhận diện đúng là "Now Playing" app trên Lock Screen / Control Center.
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
      ),
    );
  }

  void _listenToPlayer() {
    _playingSubscription = _player.playingStream.listen((playing) {
      isPlaying.value = playing;
      if (playing) {
        hasActiveSession.value = true;
      }
      // Khi timer đang hoạt động, dùng timer-elapsed position để lock screen không bị drift.
      // Khi không có timer, dùng audio file position bình thường.
      _handler.setPlaybackState(
        playing: playing,
        position: _timerElapsedPosition(),
      );
    });
    _volumeSubscription = _player.volumeStream.listen((v) => volume.value = v);
  }

  /// Vị trí hiệu quả cho lock screen:
  /// - Timer active → thời gian đã trôi qua của timer (tránh drift do audio loop)
  /// - Không có timer → vị trí thực của audio player
  Duration _timerElapsedPosition() {
    final stopAt = _scheduledStopAt;
    if (stopAt == null) return _player.position;
    final timerDuration = Duration(minutes: timerMinutes.value);
    final remaining = stopAt.difference(DateTime.now());
    final elapsed = timerDuration - remaining;
    if (elapsed < Duration.zero) return Duration.zero;
    if (elapsed > timerDuration) return timerDuration;
    return elapsed;
  }

  Future<void> loadSound(SoundModel sound) async {
    if (sound.isPremium && !_repository.isPremium) {
      Get.toNamed(Routes.premium);
      return;
    }
    await _player.stop();
    try {
      await _player.setAsset(sound.assetPath);
      await _player.setLoopMode(LoopMode.one);
      currentSound.value = sound;
      // Cập nhật metadata notification khi load sound mới.
      // Truyền duration để iOS hiển thị đúng thanh tiến trình.
      _handler.setNowPlaying(
        id: sound.id,
        title: sound.title,
        artist: 'Sleep Heaven',
        duration: _player.duration,
      );
    } catch (e) {
      Get.snackbar('Error', 'Could not load sound: $e');
    }
  }

  Future<void> play() async {
    if (currentSound.value == null) return;
    // Đăng ký controller này làm chủ notification khi bắt đầu phát
    _ownershipToken = _handler.acquireOwnership(
      ownerId: _ownerId,
      onPlayRequested: _playFromRemote,
      onPauseRequested: _pauseFromRemote,
    );
    // Không await: với LoopMode.one, play() chỉ resolve khi bị interrupt (loop vô hạn).
    // Nếu await thì _startTimerIfSet() sẽ không bao giờ được gọi.
    _player.play(); // ignore: unawaited_futures
    _startTimerIfSet();
  }

  Future<void> pause() async {
    await _player.pause();
    _cancelTimers();
  }

  void _playFromRemote() {
    play();
  }

  void _pauseFromRemote() {
    pause();
  }

  Future<void> stop() async {
    await _player.stop();
    _resetSleepTimerState();
    _releaseOwnership();
    hasActiveSession.value = false;
  }

  Future<void> setVolume(double v) async {
    volume.value = v.clamp(0.0, 1.0);
    await _player.setVolume(volume.value);
  }

  void setTimer(int minutes) {
    timerMinutes.value = minutes;
    if (minutes <= 0) {
      // Tắt timer: hủy đếm ngược, xóa hiển thị timer trên lock screen
      _cancelTimers();
      remainingTime.value = Duration.zero;
      _handler.clearTimer(_player.duration);
      if (isPlaying.value) {
        _handler.setPlaybackState(playing: true, position: Duration.zero);
      }
    } else if (isPlaying.value) {
      _startTimerIfSet();
    }
  }

  void _startTimerIfSet() {
    _cancelTimers();
    if (timerMinutes.value <= 0) return;

    _scheduledStopAt = DateTime.now().add(
      Duration(minutes: timerMinutes.value),
    );
    final timerDuration = Duration(minutes: timerMinutes.value);
    remainingTime.value = timerDuration;

    // Cập nhật lock screen ngay lập tức: duration = timer total, artist = thời gian còn lại
    _handler.setTimerDuration(timerDuration);
    _handler.updateTimerNotification(timerDuration);
    _handler.setPlaybackState(playing: true, position: Duration.zero);

    // Timer duy nhất với wall-clock comparison — dù iOS throttle, khi fire sẽ detect đúng
    _timerCountdown = Timer.periodic(const Duration(seconds: 1), (_) {
      final stopAt = _scheduledStopAt;
      if (stopAt == null) return;
      final remaining = stopAt.difference(DateTime.now());
      if (remaining <= Duration.zero) {
        remainingTime.value = Duration.zero;
        _cancelTimers();
        _handler.clearTimer(_player.duration);
        _fadeOutAndStop();
      } else {
        remainingTime.value = remaining;
        // Cập nhật artist field với countdown và position với elapsed time
        _handler.updateTimerNotification(remaining);
        _handler.setPlaybackState(
          playing: true,
          position: timerDuration - remaining,
        );
      }
    });
  }

  void _cancelTimers() {
    _timerCountdown?.cancel();
    _timerCountdown = null;
    _scheduledStopAt = null;
  }

  void _resetSleepTimerState() {
    _cancelTimers();
    // Xóa timer trên lock screen và khôi phục audio file duration.
    _handler.clearTimer(_player.duration);
    remainingTime.value = Duration.zero;
    timerMinutes.value = 0;
  }

  Future<void> _fadeOutAndStop() async {
    final currentVol = _player.volume;
    await AudioHelpers.fadeOut(currentVol, 3000, (v) => _player.setVolume(v));
    await stop();
    // Restore volume về 1.0 sau khi dừng, tránh lần phát tiếp theo bị tắt tiếng
    await _player.setVolume(1.0);
    volume.value = 1.0;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelTimers();
    _playingSubscription?.cancel();
    _volumeSubscription?.cancel();
    _releaseOwnership();
    _player.dispose(); // ignore: discarded_futures
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
