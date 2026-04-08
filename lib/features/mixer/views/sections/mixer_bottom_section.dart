import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          controller.isPlayingRx.value ? 'Active' : 'Paused',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white54,
                              ),
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
