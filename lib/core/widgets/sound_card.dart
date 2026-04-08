import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../../data/repositories/sound_repository.dart';

/// Card hiển thị một sound - icon, tên, lock nếu premium chưa mua, trạng thái playing, favorite
class SoundCard extends StatelessWidget {
  const SoundCard({
    super.key,
    required this.title,
    required this.onTap,
    this.icon = Icons.music_note,
    this.isPremium = false,
    this.isPlaying = false,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onPremiumTap,
  });

  final String title;
  final VoidCallback onTap;
  final VoidCallback? onPremiumTap;
  final IconData icon;
  final bool isPremium;
  final bool isPlaying;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final repo = Get.find<SoundRepository>();
      final isLocked = isPremium && !repo.isPremium;
      return Card(
        child: InkWell(
          onTap: isLocked ? onPremiumTap : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryStart.opacityColor(0.3),
                            AppColors.primaryEnd.opacityColor(0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 28,
                        color: AppColors.primaryStart,
                      ),
                    ),
                    if (isLocked)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Icon(
                          Icons.lock,
                          size: 18,
                          color: AppColors.premium,
                        ),
                      ),
                    if (isPlaying)
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryStart,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Playing',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (onFavoriteTap != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onFavoriteTap,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isFavorite ? AppColors.favorite : null,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
