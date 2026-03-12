import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/utils/audio_helpers.dart';
import '../../../data/models/sound_model.dart';
import '../../../data/repositories/sound_repository.dart';
import '../../../routes/app_routes.dart';

class PlayerController extends GetxController {
  final SoundRepository _repository = Get.find<SoundRepository>();

  final AudioPlayer _player = AudioPlayer();

  final Rx<SoundModel?> currentSound = Rx<SoundModel?>(null);
  final RxBool isPlaying = false.obs;
  final RxDouble volume = 1.0.obs;
  final RxInt timerMinutes = 0.obs;
  final Rx<Duration> remainingTime = Duration.zero.obs;

  Timer? _timerCountdown;
  Timer? _sleepTimer;

  AudioPlayer get player => _player;

  @override
  void onInit() {
    super.onInit();
    _initAudioSession();
    _listenToPlayer();
    final args = Get.arguments;
    if (args is SoundModel) {
      loadSound(args);
    }
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
    ));
  }

  void _listenToPlayer() {
    _player.playingStream.listen((playing) => isPlaying.value = playing);
    _player.volumeStream.listen((v) => volume.value = v);
  }

  Future<void> loadSound(SoundModel sound) async {
    if (sound.isPremium && !_repository.isPremium) {
      Get.toNamed(Routes.premium);
      return;
    }
    await _player.stop();
    currentSound.value = sound;
    try {
      await _player.setAsset(sound.assetPath);
      await _player.setLoopMode(LoopMode.one);
    } catch (e) {
      Get.snackbar('Error', 'Could not load sound: $e');
    }
  }

  Future<void> play() async {
    if (currentSound.value == null) return;
    await _player.play();
    _startTimerIfSet();
  }

  Future<void> pause() async {
    await _player.pause();
    _cancelTimers();
  }

  Future<void> stop() async {
    await _player.stop();
    _cancelTimers();
    remainingTime.value = Duration.zero;
  }

  Future<void> setVolume(double v) async {
    volume.value = v.clamp(0.0, 1.0);
    await _player.setVolume(volume.value);
  }

  void setTimer(int minutes) {
    timerMinutes.value = minutes;
    if (minutes > 0 && isPlaying.value) {
      _startTimerIfSet();
    }
  }

  void _startTimerIfSet() {
    _cancelTimers();
    if (timerMinutes.value <= 0) return;
    var remaining = Duration(minutes: timerMinutes.value);
    remainingTime.value = remaining;
    _timerCountdown = Timer.periodic(const Duration(seconds: 1), (_) {
      remaining = remaining - const Duration(seconds: 1);
      remainingTime.value = remaining;
      if (remaining <= Duration.zero) {
        _cancelTimers();
        _fadeOutAndStop();
      }
    });
    _sleepTimer = Timer(Duration(minutes: timerMinutes.value), () {
      _fadeOutAndStop();
    });
  }

  void _cancelTimers() {
    _timerCountdown?.cancel();
    _timerCountdown = null;
    _sleepTimer?.cancel();
    _sleepTimer = null;
  }

  Future<void> _fadeOutAndStop() async {
    _cancelTimers();
    final currentVol = _player.volume;
    await AudioHelpers.fadeOut(
      currentVol,
      3000,
      (v) => _player.setVolume(v),
    );
    await stop();
  }

  @override
  void onClose() {
    _cancelTimers();
    _player.dispose();
    super.onClose();
  }
}
