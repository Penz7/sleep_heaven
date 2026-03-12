import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/repositories/sound_repository.dart';
import '../controllers/mixer_controller.dart';

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
                    child: _ActiveSoundsList(),
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

class _MixerHeader extends StatelessWidget {
  const _MixerHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassCircleIconButton(
            icon: Icons.close,
            onTap: () => Get.back(),
          ),
          Text(
            AppStrings.mixer,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(
            width: 40,
          ),
        ],
      ),
    );
  }
}

class _ActiveSoundsList extends GetView<MixerController> {
  const _ActiveSoundsList({Key? key}) : super(key: key);

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
              Text(
                'Add up to 3 sounds to mix',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        );
      }

      final playingCount = controller.tracks.length;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ACTIVE SOUNDS',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.4,
                        color: AppColors.accent,
                      ),
                ),
                Text(
                  '$playingCount playing',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...controller.tracks.entries.map(
              (entry) => _MixerTrackCard(
                soundId: entry.key,
                track: entry.value,
                onRemove: () => controller.removeTrack(entry.key),
                onVolumeChanged: (v) =>
                    controller.setTrackVolume(entry.key, v),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }
}

class _MixerTrackCard extends StatelessWidget {
  const _MixerTrackCard({
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
  Widget build(BuildContext context) {
    final title = track.sound.title;
    final category = track.sound.categoryId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _iconForCategory(category),
                        color: AppColors.accent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          category,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white54,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () {
                final volume = (track.volume.value * 100).round();
                return Row(
                  children: [
                    Icon(
                      volume > 0 ? Icons.volume_up : Icons.volume_mute,
                      size: 18,
                      color:
                          volume > 0 ? AppColors.accent : Colors.white54,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                        ),
                        child: Slider(
                          value: track.volume.value,
                          onChanged: onVolumeChanged,
                          activeColor: AppColors.accent,
                          inactiveColor: Colors.white12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '$volume%',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForCategory(String categoryId) {
    switch (categoryId) {
      case 'rain':
        return Icons.cloudy_snowing;
      case 'nature':
        return Icons.forest;
      case 'storm':
        return Icons.bolt;
      case 'wind':
        return Icons.air;
      default:
        return Icons.graphic_eq;
    }
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

class _GlassCircleIconButton extends StatelessWidget {
  const _GlassCircleIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
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
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
