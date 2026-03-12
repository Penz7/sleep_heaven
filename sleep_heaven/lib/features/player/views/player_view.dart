import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../routes/app_routes.dart';
import '../controllers/player_controller.dart';

class PlayerView extends GetView<PlayerController> {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () => Get.toNamed(Routes.premium),
          ),
        ],
      ),
      body: GetX<PlayerController>(
        builder: (ctrl) {
          if (ctrl.currentSound.value == null) {
            return const Center(
              child: Text('Select a sound to play'),
            );
          }
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.backgroundDark, AppColors.cardDark],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      ctrl.currentSound.value!.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryStart.withOpacity(0.5),
                            AppColors.primaryEnd.withOpacity(0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.music_note,
                        size: 60,
                        color: AppColors.primaryStart,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.volume_down),
                              onPressed: () {
                                final v = (ctrl.volume.value - 0.1).clamp(0.0, 1.0);
                                ctrl.setVolume(v);
                              },
                            ),
                            Slider(
                              value: ctrl.volume.value,
                              onChanged: (v) => ctrl.setVolume(v),
                              activeColor: AppColors.primaryStart,
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up),
                              onPressed: () {
                                final v = (ctrl.volume.value + 0.1).clamp(0.0, 1.0);
                                ctrl.setVolume(v);
                              },
                            ),
                          ],
                        )),
                    const SizedBox(height: 24),
                    Text(AppStrings.timer, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [0, 15, 30, 45, 60, 90].map((m) {
                          final isSelected = ctrl.timerMinutes.value == m;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(m == 0 ? 'Off' : '${m}m'),
                              selected: isSelected,
                              onSelected: (_) => ctrl.setTimer(m),
                              selectedColor: AppColors.primaryStart.withOpacity(0.5),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    if (ctrl.timerMinutes.value > 0 && ctrl.remainingTime.value > Duration.zero)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'Remaining: ${ctrl.remainingTime.value.formatted}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    const Spacer(),
                    Obx(() => CustomButton(
                          label: ctrl.isPlaying.value ? AppStrings.pause : AppStrings.play,
                          icon: ctrl.isPlaying.value ? Icons.pause : Icons.play_arrow,
                          onPressed: () async {
                            if (ctrl.isPlaying.value) {
                              await ctrl.pause();
                            } else {
                              await ctrl.play();
                            }
                          },
                        )),
                    const SizedBox(height: 16),
                    CustomButton(
                      label: AppStrings.stop,
                      icon: Icons.stop,
                      isOutlined: true,
                      onPressed: () => ctrl.stop(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
