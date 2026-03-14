import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../routes/app_routes.dart';
import '../controllers/library_controller.dart';

class LibraryView extends GetView<LibraryController> {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.backgroundDark,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark.opacityColor(0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.opacityColor(0.4),
                offset: const Offset(0, 4),
                blurRadius: 16,
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
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
                  AppStrings.library,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: const _LibraryContent(),
    );
  }
}

class _LibraryContent extends StatelessWidget {
  const _LibraryContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.backgroundDark, AppColors.cardDark],
        ),
      ),
      child: GetBuilder<LibraryController>(
        builder: (c) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 96),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _buildTab('All', 0, c),
                  ...List.generate(
                    c.categories.length,
                    (i) => _buildTab(c.categories[i].name, i + 1, c),
                  ),
                  _buildTab(AppStrings.favorites, c.categories.length + 1, c),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: GridView.builder(
                  key: ValueKey(c.selectedTabIndex),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: c.sounds.length,
                  itemBuilder: (context, index) {
                    final sound = c.sounds[index];
                    return _AnimatedSoundCard(
                      index: index,
                      child: _BubbleSoundCard(
                        title: sound.title,
                        icon: _getIconForCategory(sound.categoryId),
                        isPremium: sound.isPremium,
                        isFavorite: c.isFavorite(sound.id),
                        onFavoriteTap: () => c.toggleFavorite(sound.id),
                        onPremiumTap: () => Get.toNamed(Routes.premium),
                        onTap: () =>
                            Get.toNamed(Routes.player, arguments: sound),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index, LibraryController c) {
    final isSelected = c.selectedTabIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => c.selectTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accent
                : Colors.white.opacityColor(0.06),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String categoryId) {
    switch (categoryId) {
      case 'rain':
        return Icons.cloudy_snowing;
      case 'white_noise':
        return Icons.graphic_eq;
      case 'baby':
        return Icons.child_care;
      case 'nature':
        return Icons.forest_sharp;
      default:
        return Icons.music_note;
    }
  }
}

class _BubbleSoundCard extends StatelessWidget {
  const _BubbleSoundCard({
    required this.title,
    required this.icon,
    required this.onTap,
    this.onFavoriteTap,
    this.onPremiumTap,
    this.isPremium = false,
    this.isFavorite = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onPremiumTap;
  final bool isPremium;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPremium ? (onPremiumTap ?? onTap) : onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPremium ? [
              AppColors.backgroundDark.opacityColor(0.35),
              AppColors.cardDark.opacityColor(0.5),
            ] : [
              AppColors.backgroundDark,
              AppColors.accent.opacityColor(0.3),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.opacityColor(0.35),
              offset: const Offset(0, 10),
              blurRadius: 30,
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: Colors.white.opacityColor(0.04),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.opacityColor(0.15),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  // Thêm param mới
                  if (onFavoriteTap != null)
                    GestureDetector(
                      onTap: isPremium ? null : onFavoriteTap,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.elasticOut,
                          scale: (isPremium) || isFavorite ? 1.2 : 1.0,
                          child: isPremium
                              ? Icon(
                                  Icons.lock,
                                  color: Colors.amber[300],
                                  size: 20,
                                  shadows: [
                                    Shadow(
                                      color: Colors.amber.opacityColor(0.7),
                                      blurRadius: 10,
                                    ),
                                  ],
                                )
                              : isFavorite
                              ? Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 20,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.favorite.opacityColor(
                                        0.7,
                                      ),
                                      blurRadius: 10,
                                    ),
                                  ],
                                )
                              : Icon(
                                  Icons.favorite_border,
                                  color: Colors.white.opacityColor(0.75),
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                ],
              ),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedSoundCard extends StatefulWidget {
  const _AnimatedSoundCard({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_AnimatedSoundCard> createState() => _AnimatedSoundCardState();
}

class _AnimatedSoundCardState extends State<_AnimatedSoundCard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    final delay = Duration(milliseconds: 70 * widget.index);
    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        final slideY = 28 * (1 - value);
        final scale = 0.8 + 0.2 * value;

        return Transform.translate(
          offset: Offset(0, slideY),
          child: Transform.scale(
            scale: scale,
            child: Opacity(opacity: value, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}
