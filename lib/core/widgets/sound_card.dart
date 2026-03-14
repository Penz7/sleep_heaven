import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Card hiển thị một sound - icon, tên, lock nếu premium, trạng thái playing, favorite
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
    return Card(
      child: InkWell(
        onTap: isPremium ? onPremiumTap : onTap,
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
                    child: Icon(icon, size: 28, color: AppColors.primaryStart),
                  ),
                  if (isPremium)
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
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
  }
}
