import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/local_track_model.dart';
import '../controllers/local_music_controller.dart';

/// Bottom sheet hiển thị danh sách local tracks và nút thêm mới
class LocalMusicSheet extends GetView<LocalMusicController> {
  const LocalMusicSheet({
    super.key,
    this.onTrackSelected,
  });

  final void Function(LocalTrackModel track)? onTrackSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
      decoration: const BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'From Device',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () async {
                    await controller.pickAndAddTrack();
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
          Flexible(
            child: Obx(() {
              if (controller.localTracks.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.music_note, size: 48, color: Colors.white38),
                        const SizedBox(height: 12),
                        Text(
                          'No music yet. Tap + to add from your device.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: controller.localTracks.length,
                itemBuilder: (context, index) {
                  final track = controller.localTracks[index];
                  return ListTile(
                    leading: const Icon(Icons.audio_file, color: AppColors.accent),
                    title: Text(
                      track.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => onTrackSelected?.call(track),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.white54),
                          onPressed: () => controller.removeTrack(track.id),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
