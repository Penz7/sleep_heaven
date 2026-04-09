import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/sound_repository.dart';
import '../../../routes/app_routes.dart';
import '../../local_music/controllers/local_music_controller.dart';
import '../../local_music/views/local_music_sheet.dart';
import '../../player/controllers/player_controller.dart';
import '../controllers/mixer_controller.dart';
import 'sections/active_sounds_section.dart';
import 'sections/mixer_bottom_section.dart';
import 'sections/mixer_header_section.dart';

class MixerView extends StatefulWidget {
  const MixerView({super.key});

  @override
  State<MixerView> createState() => _MixerViewState();
}

class _MixerViewState extends State<MixerView> {
  late final MixerController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<MixerController>();
    if (Get.isRegistered<PlayerController>()) {
      Get.find<PlayerController>().stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundDark, AppColors.cardDark],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const MixerHeaderSection(),
                  const Expanded(child: ActiveSoundsSection()),
                  SizedBox(height: size.height * 0.18),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: MixerBottomSection(
                  controller: controller,
                  onAddSound: () => _showAddSoundSheet(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSoundSheet(BuildContext context) {
    Get.bottomSheet(_AddSoundSheet(controller: controller));
  }
}

class _AddSoundSheet extends StatefulWidget {
  const _AddSoundSheet({required this.controller});

  final MixerController controller;

  @override
  State<_AddSoundSheet> createState() => _AddSoundSheetState();
}

class _AddSoundSheetState extends State<_AddSoundSheet> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<SoundRepository>();
    final sounds = repo.getAllSounds();
    final localMusicCtrl = Get.find<LocalMusicController>();

    return Container(
      height: 450,
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
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => setState(() => _selectedTab = 0),
                  child: Text(
                    'Default',
                    style: TextStyle(
                      color: _selectedTab == 0 ? AppColors.accent : null,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  final isPremium = localMusicCtrl.isPremium;
                  return TextButton(
                    onPressed: () {
                      if (!isPremium) {
                        Get.back();
                        Get.toNamed(Routes.premium);
                      } else {
                        setState(() => _selectedTab = 1);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isPremium) ...[
                          const Icon(Icons.lock, size: 16),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          'From Device',
                          style: TextStyle(
                            color: _selectedTab == 1 ? AppColors.accent : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
          Expanded(
            child: _selectedTab == 0
                ? Obx(() {
                    final isPremium = repo.isPremium;
                    return ListView.builder(
                      itemCount: sounds.length,
                      itemBuilder: (context, index) {
                        final sound = sounds[index];
                        final alreadyAdded = widget.controller.tracks
                            .containsKey(sound.id);
                        final isLocked =
                            sound.isPremium && !isPremium && !alreadyAdded;
                        return ListTile(
                          title: Text(sound.title),
                          trailing: alreadyAdded
                              ? const Icon(Icons.check)
                              : IconButton(
                                  icon: Icon(isLocked ? Icons.lock : Icons.add),
                                  onPressed: () {
                                    Get.back();
                                    widget.controller.addTrack(sound);
                                  },
                                ),
                        );
                      },
                    );
                  })
                : Obx(() {
                    if (!localMusicCtrl.isPremium) {
                      return const Center(
                        child: Text(
                          'Premium is required to add music from your device',
                        ),
                      );
                    }
                    return LocalMusicSheet(
                      onTrackSelected: (track) {
                        Get.back();
                        widget.controller.addLocalTrack(track);
                      },
                    );
                  }),
          ),
        ],
      ),
    );
  }
}
