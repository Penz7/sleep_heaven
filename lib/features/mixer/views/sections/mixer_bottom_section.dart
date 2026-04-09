import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../controllers/mixer_controller.dart';
import '../mixer_perf_tier.dart';
import '../widgets/glass_container.dart';

class MixerBottomSection extends StatelessWidget {
  const MixerBottomSection({
    super.key,
    required this.controller,
    required this.onAddSound,
  });

  final MixerController controller;
  final VoidCallback onAddSound;
  static const List<(int, String)> _timerOptions = <(int, String)>[
    (15, '15m'),
    (30, '30m'),
    (45, '45m'),
    (60, '1h'),
  ];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Obx(
            () => GlassContainer(
              tier: MixerPerfTier.capable,
              borderRadius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.remainingTime.value > Duration.zero
                            ? 'Timer: ${controller.remainingTime.value.formatted}'
                            : 'Sleep timer',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        _TimerChip(
                          label: 'Off',
                          selected: controller.timerMinutes.value == 0,
                          onTap: () => controller.setTimer(0),
                        ),
                        const SizedBox(width: 8),
                        ..._timerOptions.map(
                          ((int, String) option) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _TimerChip(
                              label: option.$2,
                              selected:
                                  controller.timerMinutes.value == option.$1,
                              onTap: () => controller.setTimer(option.$1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => GlassContainer(
              tier: MixerPerfTier.capable,
              borderRadius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: <Color>[
                          AppColors.primaryStart,
                          AppColors.accent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        controller.isPlayingRx.value
                            ? Icons.graphic_eq
                            : Icons.music_note,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Deep Sleep Mix',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          controller.isPlayingRx.value ? 'Active' : 'Paused',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () async {
                        if (controller.isPlayingRx.value) {
                          await controller.pauseAll();
                        } else {
                          await controller.playAll();
                        }
                      },
                      icon: Icon(
                        controller.isPlayingRx.value
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: AppColors.backgroundDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.stopAll,
                    icon: const Icon(Icons.stop),
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => controller.canAddTrack
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onAddSound,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryStart,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Add Sound',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
