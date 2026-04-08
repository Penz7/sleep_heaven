import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/mixer_controller.dart';
import '../widgets/active_sounds_header.dart';
import '../widgets/glass_container.dart';
import '../widgets/mixer_track_card.dart';
import '../mixer_perf_tier.dart';

class ActiveSoundsSection extends GetView<MixerController> {
  const ActiveSoundsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.tracks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.tune, size: 64, color: Colors.white38),
              const SizedBox(height: 16),
              Obx(
                () => Text(
                  'Add up to ${controller.maxTracks} sounds to mix',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        );
      }

      final int playingCount = controller.tracks.length;
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
  State<_AnimatedMixerTrackCard> createState() => _AnimatedMixerTrackCardState();
}

class _AnimatedMixerTrackCardState extends State<_AnimatedMixerTrackCard> {
  double _opacity = 0.0;
  Offset _offset = const Offset(0, 0.08);

  @override
  void initState() {
    super.initState();
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
    Future<void>.delayed(const Duration(milliseconds: 200), () {
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
              GlassContainer(
                tier: MixerPerfTier.capable,
                padding: padding,
                borderRadius: borderRadius,
                child: child,
              ),
        ),
      ),
    );
  }
}
