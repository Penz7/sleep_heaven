import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/services/audio_handler.dart';
import '../../../core/utils/audio_helpers.dart';
import '../../../data/models/sound_model.dart';
import '../../../data/repositories/sound_repository.dart';
import '../../../routes/app_routes.dart';

class PlayerController extends GetxController {
  final SoundRepository _repository = Get.find<SoundRepository>();
  late final SleepAudioHandler _handler;

  final AudioPlayer _player = AudioPlayer();

  final Rx<SoundModel?> currentSound = Rx<SoundModel?>(null);
  final RxBool isPlaying = false.obs;
  final RxDouble volume = 1.0.obs;
  final RxInt timerMinutes = 0.obs;
  final Rx<Duration> remainingTime = Duration.zero.obs;

  Timer? _timerCountdown;
  DateTime? _timerEndTime;

  AudioPlayer get player => _player;

  @override
  void onInit() {
    super.onInit();
    _handler = Get.find<SleepAudioHandler>();
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
    _player.playingStream.listen((playing) {
      final wasPlaying = isPlaying.value;
      isPlaying.value = playing;
      _handler.setPlaybackState(playing: playing);
      if (playing && !wasPlaying && timerMinutes.value > 0 && _timerEndTime == null) {
        _resumeOrStartTimer();
      }
    });
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
      _handler.setNowPlaying(
        id: sound.id,
        title: sound.title,
        artist: 'Sleep Heaven',
      );
    } catch (e) {
      Get.snackbar('Error', 'Could not load sound: $e');
    }
  }

  Future<void> play() async {
    if (currentSound.value == null) return;
    _handler.onPlayRequested = play;
    _handler.onPauseRequested = pause;
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
    _syncRemainingFromEndTime();
    _cancelTimerTicker();
    _timerEndTime = null;
  }

  Future<void> stop() async {
    await _player.stop();
    _cancelTimerTicker();
    _timerEndTime = null;
    remainingTime.value = Duration.zero;
    _handler.clearTimerNotification();
  }

  Future<void> setVolume(double v) async {
    volume.value = v.clamp(0.0, 1.0);
    await _player.setVolume(volume.value);
  }

  void setTimer(int minutes) {
    timerMinutes.value = minutes;
    if (minutes <= 0) {
      _cancelTimerTicker();
      _timerEndTime = null;
      remainingTime.value = Duration.zero;
      _handler.clearTimerNotification();
      return;
    }
    remainingTime.value = Duration(minutes: minutes);
    if (isPlaying.value) {
      _startTimerFromRemaining();
    }
  }

  void _resumeOrStartTimer() {
    if (timerMinutes.value <= 0) return;
    if (remainingTime.value <= Duration.zero) {
      remainingTime.value = Duration(minutes: timerMinutes.value);
    }
    _startTimerFromRemaining();
  }

  void _startTimerFromRemaining() {
    _cancelTimerTicker();
    final remaining = remainingTime.value;
    if (remaining <= Duration.zero) return;
    _timerEndTime = DateTime.now().add(remaining);
    _timerCountdown = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncRemainingFromEndTime();
      if (remainingTime.value <= Duration.zero) {
        _cancelTimerTicker();
        _timerEndTime = null;
        _fadeOutAndStop();
      }
    });
  }

  void _syncRemainingFromEndTime() {
    if (_timerEndTime == null) return;
    final now = DateTime.now();
    final diff = _timerEndTime!.difference(now);
    remainingTime.value = diff > Duration.zero ? diff : Duration.zero;
    if (remainingTime.value > Duration.zero) {
      _handler.updateTimerNotification(remainingTime.value);
    }
  }

  void _cancelTimerTicker() {
    _timerCountdown?.cancel();
    _timerCountdown = null;
  }

  Future<void> _fadeOutAndStop() async {
    _cancelTimerTicker();
    final savedVol = volume.value;
    await AudioHelpers.fadeOut(
      _player.volume,
      3000,
      (v) => _player.setVolume(v),
    );
    await stop();
    await setVolume(savedVol > 0 ? savedVol : 1.0);
    timerMinutes.value = 0;
  }

  @override
  void onClose() {
    _cancelTimerTicker();
    _player.dispose();
    super.onClose();
  }
}
