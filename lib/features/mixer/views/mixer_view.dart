import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/repositories/sound_repository.dart';
import '../../../routes/app_routes.dart';
import '../../local_music/controllers/local_music_controller.dart';
import '../../local_music/views/local_music_sheet.dart';
import '../controllers/mixer_controller.dart';
import 'widgets/active_sounds_header.dart';
import 'widgets/mixer_track_card.dart';

class MixerView extends GetView<MixerController> {
  const MixerView({super.key});

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
                  const _MixerHeader(),
                  const Expanded(
                    child: ActiveSoundsList(),
                  ),
                  SizedBox(height: size.height * 0.18),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _MixerBottomArea(
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
    Get.bottomSheet(
      _AddSoundSheet(
        controller: controller,
      ),
    );
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
                child: Obx(
                  () {
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
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: _selectedTab == 0
                ? Obx(
                    () {
                      final isPremium = repo.isPremium;
                      return ListView.builder(
                        itemCount: sounds.length,
                        itemBuilder: (context, index) {
                          final sound = sounds[index];
                          final alreadyAdded =
                              widget.controller.tracks.containsKey(sound.id);
                          final isLocked = sound.isPremium &&
                              !isPremium &&
                              !alreadyAdded;
                          return ListTile(
                            title: Text(sound.title),
                            trailing: alreadyAdded
                                ? const Icon(Icons.check)
                                : IconButton(
                                    icon: Icon(
                                      isLocked ? Icons.lock : Icons.add,
                                    ),
                                    onPressed: () {
                                      Get.back();
                                      widget.controller.addTrack(sound);
                                    },
                                  ),
                          );
                        },
                      );
                    },
                  )
                : Obx(
                    () {
                      if (!localMusicCtrl.isPremium) {
                        return const Center(
                          child: Text('Premium is required to add music from your device'),
                        );
                      }
                      return LocalMusicSheet(
                        onTrackSelected: (track) {
                          Get.back();
                          widget.controller.addLocalTrack(track);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MixerHeader extends StatelessWidget {
  const _MixerHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              Get.back();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accent.opacityColor(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                size: 20,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Text(
            AppStrings.mixer,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class ActiveSoundsList extends GetView<MixerController> {
  const ActiveSoundsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.tracks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.tune, size: 64, color: Colors.white38),
              const SizedBox(height: 16),
              Obx(
                () => Text(
                  'Add up to ${controller.maxTracks} sounds to mix',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        );
      }

      final playingCount = controller.tracks.length;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView.builder(
          cacheExtent: 600,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: controller.tracks.length + 3,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return ActiveSoundsHeader(playingCount: playingCount);
            }
            if (index == 1) {
              return const SizedBox(height: 12);
            }
            if (index == controller.tracks.length + 2) {
              return const SizedBox(height: 24);
            }

            final int trackIndex = index - 2;
            final MapEntry<String, MixerTrack> entry =
                controller.tracks.entries.elementAt(trackIndex);
            return _AnimatedMixerTrackCard(
              key: ValueKey<String>(entry.key),
              soundId: entry.key,
              track: entry.value,
              onRemove: () => controller.removeTrack(entry.key),
              onVolumeChanged: (double v) =>
                  controller.setTrackVolume(entry.key, v),
            );
          },
        ),
      );
    });
  }
}

class _AnimatedMixerTrackCard extends StatefulWidget {
  const _AnimatedMixerTrackCard({
    super.key,
    required this.soundId,
    required this.track,
    required this.onRemove,
    required this.onVolumeChanged,
  });

  final String soundId;
  final dynamic track;
  final VoidCallback onRemove;
  final ValueChanged<double> onVolumeChanged;

  @override
  State<_AnimatedMixerTrackCard> createState() =>
      _AnimatedMixerTrackCardState();
}

class _AnimatedMixerTrackCardState extends State<_AnimatedMixerTrackCard>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  Offset _offset = const Offset(0, 0.08);

  @override
  void initState() {
    super.initState();
    // Fade in from bottom when item được thêm
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _offset = Offset.zero;
        });
      }
    });
  }

  void _handleRemove() {
    setState(() {
      _opacity = 0.0;
      _offset = const Offset(0, 0.08);
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        widget.onRemove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      offset: _offset,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _opacity,
        child: MixerTrackCard(
          soundId: widget.soundId,
          track: widget.track,
          onRemove: _handleRemove,
          onVolumeChanged: widget.onVolumeChanged,
          glassBuilder: ({
            required Widget child,
            EdgeInsetsGeometry? padding,
            double borderRadius = 16,
          }) =>
              _GlassContainer(
                padding: padding,
                borderRadius: borderRadius,
                child: child,
              ),
        ),
      ),
    );
  }
}

class _MixerBottomArea extends StatelessWidget {
  const _MixerBottomArea({
    required this.controller,
    required this.onAddSound,
  });

  final MixerController controller;
  final VoidCallback onAddSound;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => _GlassContainer(
              borderRadius: 20,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
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
                      children: [
                        Text(
                          'Deep Sleep Mix',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          controller.isPlayingRx.value
                              ? 'Active'
                              : 'Paused',
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
                    onPressed: () => controller.stopAll(),
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
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
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

class _GlassContainer extends StatelessWidget {
  const _GlassContainer({
    required this.child,
    this.padding,
    this.borderRadius = 16,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding ?? const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.white.opacityColor(0.05),
            border: Border.all(
              color: Colors.white.opacityColor(0.12),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
