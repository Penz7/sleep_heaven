import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/sound_card.dart';
import '../../../data/models/sound_model.dart';
import '../../../routes/app_routes.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundDark,
              AppColors.cardDark,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(
                  AppStrings.appName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.library_music),
                    onPressed: () => Get.toNamed(Routes.library),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () => Get.toNamed(Routes.mixer),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured Sounds',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      GetBuilder<HomeController>(
                        builder: (_) => _buildSoundGrid(controller.featuredSounds),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Categories',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ...controller.categories.map((cat) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat.name,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                GetBuilder<HomeController>(
                                  builder: (_) => _buildSoundGrid(
                                      controller.getSoundsByCategory(cat.id)),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundGrid(List<SoundModel> sounds) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: sounds.length,
      itemBuilder: (context, index) {
        final sound = sounds[index];
        return SoundCard(
          title: sound.title,
          icon: _getIconForCategory(sound.categoryId),
          isPremium: sound.isPremium,
          isFavorite: controller.isFavorite(sound.id),
          onFavoriteTap: () => controller.toggleFavorite(sound.id),
          onPremiumTap: () => Get.toNamed(Routes.premium),
          onTap: () => Get.toNamed(Routes.player, arguments: sound),
        );
      },
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
