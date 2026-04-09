import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../mixer/controllers/mixer_controller.dart';
import '../controllers/player_controller.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({super.key});

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  late final PlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<PlayerController>();
    if (Get.isRegistered<MixerController>()) {
      final MixerController mixerController = Get.find<MixerController>();
      if (mixerController.hasActiveSession.value ||
          mixerController.isPlayingRx.value) {
        mixerController.stopAll();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    controller.syncRouteArguments(Get.arguments);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.backgroundDark,
      body: GetX<PlayerController>(
        builder: (ctrl) {
          if (ctrl.currentSound.value == null) {
            return Center(
              child: Text(
                'Select a sound to play',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          return Stack(
            children: [
              Positioned.fill(child: const _FallingBubblesBackground()),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: () => Get.back(),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.accent.opacityColor(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _TimerChips(ctrl: ctrl),
                        const SizedBox(height: 100),
                        _CircularVisualizer(ctrl: ctrl),
                        const SizedBox(height: 24),
                        Text(
                          ctrl.currentSound.value!.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getSubtitle(ctrl.currentSound.value!.categoryId),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white54),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // Volume control
                        _VolumeSlider(ctrl: ctrl),
                        const SizedBox(height: 40),
                        _PlaybackControls(ctrl: ctrl),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getSubtitle(String categoryId) {
    switch (categoryId) {
      case 'rain':
        return 'Deep Sleep Series';
      case 'white_noise':
        return 'White Noise Collection';
      case 'music_box':
        return 'Music Box & Lullaby';
      case 'nature':
        return 'Nature Sounds';
      default:
        return 'Relaxing Sounds';
    }
  }
}

class _TimerChips extends StatelessWidget {
  const _TimerChips({required this.ctrl});

  final PlayerController ctrl;

  static const _options = [
    (1, '1m'),
    (15, '15m'),
    (30, '30m'),
    (45, '45m'),
    (60, '1h'),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Off option
            _buildChip(context, 0, 'Off'),
            const SizedBox(width: 8),
            ..._options.map(
              (e) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildChip(context, e.$1, e.$2),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChip(BuildContext context, int minutes, String label) {
    final isSelected = ctrl.timerMinutes.value == minutes;
    return GestureDetector(
      onTap: () => ctrl.setTimer(minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent
              : Colors.white.opacityColor(0.06),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularVisualizer extends StatelessWidget {
  const _CircularVisualizer({required this.ctrl});

  final PlayerController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Off (timerMinutes=0): vòng đầy, chạy vô hạn
      // Có timer + remaining > 0: đếm ngược từ 1 về 0
      // Có timer + remaining = 0: vừa chọn timer chưa play → đầy
      double progress = 1.0;
      final totalSecs = ctrl.timerMinutes.value * 60.0;
      final remainingSecs = ctrl.remainingTime.value.inSeconds.toDouble();
      if (ctrl.timerMinutes.value > 0 && remainingSecs > 0) {
        progress = (remainingSecs / totalSecs).clamp(0.0, 1.0);
      }
      return SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Progress ring
            SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                painter: _ProgressRingPainter(
                  progress: progress.clamp(0.0, 1.0),
                  color: AppColors.accent,
                  backgroundColor: Colors.white.opacityColor(0.1),
                  strokeWidth: 8,
                ),
              ),
            ),
            // Inner content: moon when Off, countdown + status when timer active
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.opacityColor(0.2),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    ctrl.timerMinutes.value > 0 &&
                        ctrl.remainingTime.value > Duration.zero
                    ? _TimerStatusContent(
                        key: const ValueKey('timer'),
                        remaining: ctrl.remainingTime.value,
                        isPlaying: ctrl.isPlaying.value,
                      )
                    : Icon(
                        key: const ValueKey('moon'),
                        Icons.nightlight_round,
                        size: 72,
                        color: AppColors.accent,
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _TimerStatusContent extends StatelessWidget {
  const _TimerStatusContent({
    super.key,
    required this.remaining,
    required this.isPlaying,
  });

  final Duration remaining;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            remaining.formatted,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPlaying ? Icons.play_circle : Icons.pause_circle,
                size: 14,
                color: Colors.white54,
              ),
              const SizedBox(width: 4),
              Text(
                isPlaying ? 'Playing' : 'Paused',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    this.strokeWidth = 8,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;

    // Background arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter old) =>
      old.progress != progress;
}

class _VolumeSlider extends StatelessWidget {
  const _VolumeSlider({required this.ctrl});

  final PlayerController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          GestureDetector(
            onTap: () =>
                ctrl.setVolume((ctrl.volume.value - 0.1).clamp(0.0, 1.0)),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.volume_down, color: Colors.white70, size: 24),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.accent,
                inactiveTrackColor: Colors.white.opacityColor(0.15),
                thumbColor: AppColors.accent,
                overlayColor: AppColors.accent.opacityColor(0.2),
              ),
              child: Slider(
                value: ctrl.volume.value,
                onChanged: (v) => ctrl.setVolume(v),
              ),
            ),
          ),
          GestureDetector(
            onTap: () =>
                ctrl.setVolume((ctrl.volume.value + 0.1).clamp(0.0, 1.0)),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.volume_up, color: Colors.white70, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({required this.ctrl});

  final PlayerController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              if (ctrl.isPlaying.value) {
                await ctrl.pause();
              } else {
                await ctrl.play();
              }
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.opacityColor(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                ctrl.isPlaying.value ? Icons.pause : Icons.play_arrow,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Stop
          GestureDetector(
            onTap: () => ctrl.stop(),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.opacityColor(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.opacityColor(0.2)),
              ),
              child: Icon(Icons.stop, size: 28, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bong bóng rơi từ trên xuống ngẫu nhiên
class _FallingBubblesBackground extends StatefulWidget {
  const _FallingBubblesBackground();

  @override
  State<_FallingBubblesBackground> createState() =>
      _FallingBubblesBackgroundState();
}

class _FallingBubblesBackgroundState extends State<_FallingBubblesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Bubble> _bubbles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    for (var i = 0; i < 12; i++) {
      _bubbles.add(_createBubble());
    }
  }

  _Bubble _createBubble() {
    return _Bubble(
      x: _random.nextDouble(),
      size: 8 + _random.nextDouble() * 16,
      speed: 0.3 + _random.nextDouble() * 0.5,
      opacity: 0.15 + _random.nextDouble() * 0.25,
      delay: _random.nextDouble(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _FallingBubblesPainter(
              progress: _controller.value,
              bubbles: _bubbles,
            ),
          );
        },
      ),
    );
  }
}

class _Bubble {
  _Bubble({
    required this.x,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.delay,
  });

  final double x;
  final double size;
  final double speed;
  final double opacity;
  final double delay;
}

class _FallingBubblesPainter extends CustomPainter {
  _FallingBubblesPainter({required this.progress, required this.bubbles});

  final double progress;
  final List<_Bubble> bubbles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in bubbles) {
      final y =
          ((progress + b.delay) % 1.0) * (size.height + b.size * 2) - b.size;
      final x = b.x * size.width;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.accent.opacityColor(b.opacity),
            AppColors.accent.opacityColor(0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(x, y), radius: b.size));
      canvas.drawCircle(Offset(x, y), b.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FallingBubblesPainter old) =>
      old.progress != progress;
}
