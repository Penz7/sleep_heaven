import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';

class MixerTrackCard extends StatelessWidget {
  const MixerTrackCard({
    super.key,
    required this.soundId,
    required this.track,
    required this.onRemove,
    required this.onVolumeChanged,
    required this.glassBuilder,
  });

  final String soundId;
  final dynamic track;
  final VoidCallback onRemove;
  final ValueChanged<double> onVolumeChanged;
  final Widget Function({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double borderRadius,
  }) glassBuilder;

  @override
  Widget build(BuildContext context) {
    final String title = track.title as String;
    final String category = track.categoryId as String;

    return Padding(
      key: ValueKey<String>(soundId),
      padding: const EdgeInsets.only(bottom: 12),
      child: glassBuilder(
        borderRadius: 20,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.accent.opacityColor(0.18),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _iconForCategory(category),
                          color: AppColors.accent,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
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
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () {
                final int volume = (track.volume.value * 100).round() as int;
                return Row(
                  children: <Widget>[
                    Icon(
                      volume > 0 ? Icons.volume_up : Icons.volume_mute,
                      size: 18,
                      color: volume > 0 ? AppColors.accent : Colors.white54,
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
                          value: track.volume.value as double,
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

  static IconData _iconForCategory(String categoryId) {
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
