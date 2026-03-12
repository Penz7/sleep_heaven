import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/sound_card.dart';
import '../../../routes/app_routes.dart';
import '../controllers/library_controller.dart';

class LibraryView extends GetView<LibraryController> {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.library),
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
        child: GetBuilder<LibraryController>(
          builder: (c) => Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildTab('All', 0, c),
                    ...List.generate(
                      c.categories.length,
                      (i) => _buildTab(
                        c.categories[i].name,
                        i + 1,
                        c,
                      ),
                    ),
                    _buildTab(AppStrings.favorites, c.categories.length + 1, c),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: c.sounds.length,
                  itemBuilder: (context, index) {
                    final sound = c.sounds[index];
                    return SoundCard(
                      title: sound.title,
                      icon: _getIconForCategory(sound.categoryId),
                      isPremium: sound.isPremium,
                      isFavorite: c.isFavorite(sound.id),
                      onFavoriteTap: () => c.toggleFavorite(sound.id),
                      onPremiumTap: () => Get.toNamed(Routes.premium),
                      onTap: () => Get.toNamed(Routes.player, arguments: sound),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index, LibraryController c) {
    final isSelected = c.selectedTabIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => c.selectTab(index),
        selectedColor: AppColors.primaryStart.withOpacity(0.5),
      ),
    );
  }

  IconData _getIconForCategory(String categoryId) {
    switch (categoryId) {
      case 'rain':
        return Icons.water_drop;
      case 'white_noise':
        return Icons.graphic_eq;
      case 'baby':
        return Icons.child_care;
      case 'nature':
        return Icons.nature;
      default:
        return Icons.music_note;
    }
  }
}
