import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/repositories/sound_repository.dart';
import '../controllers/mixer_controller.dart';

class MixerView extends GetView<MixerController> {
  const MixerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.mixer),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundDark, AppColors.cardDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (controller.tracks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.tune, size: 64, color: Colors.white38),
                          const SizedBox(height: 16),
                          Text(
                            'Add up to 3 sounds to mix',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.tracks.length,
                    itemBuilder: (context, index) {
                      final soundId = controller.tracks.keys.elementAt(index);
                      final track = controller.tracks[soundId]!;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      track.sound.title,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => controller.removeTrack(soundId),
                                  ),
                                ],
                              ),
                              Obx(() => Slider(
                                    value: track.volume.value,
                                    onChanged: (v) => controller.setTrackVolume(soundId, v),
                                    activeColor: AppColors.primaryStart,
                                  )),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomButton(
                              label: controller.isPlayingRx.value ? AppStrings.pause : AppStrings.play,
                              icon: controller.isPlayingRx.value ? Icons.pause : Icons.play_arrow,
                              onPressed: () async {
                                if (controller.isPlayingRx.value) {
                                  await controller.pauseAll();
                                } else {
                                  await controller.playAll();
                                }
                              },
                            ),
                            const SizedBox(width: 16),
                            CustomButton(
                              label: AppStrings.stop,
                              icon: Icons.stop,
                              isOutlined: true,
                              onPressed: () => controller.stopAll(),
                            ),
                          ],
                        )),
                    const SizedBox(height: 16),
                    Obx(() => controller.canAddTrack
                        ? CustomButton(
                            label: 'Add Sound',
                            icon: Icons.add,
                            isOutlined: true,
                            onPressed: () => _showAddSoundSheet(context),
                          )
                        : const SizedBox()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSoundSheet(BuildContext context) {
    final repo = Get.find<SoundRepository>();
    final sounds = repo.getAllSounds();
    Get.bottomSheet(
      Container(
        height: 400,
        decoration: const BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Add sound to mix',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: sounds.length,
                itemBuilder: (context, index) {
                  final sound = sounds[index];
                  final alreadyAdded = controller.tracks.containsKey(sound.id);
                  return ListTile(
                    title: Text(sound.title),
                    trailing: alreadyAdded
                        ? const Icon(Icons.check)
                        : IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              Get.back();
                              controller.addTrack(sound);
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
