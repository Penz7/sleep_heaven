import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/img_onboarding.png',
            width: size.width,
            height: size.height,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              children: [
                _OnboardingHeader(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: 16,
                    ),
                    child: Center(
                      child: _GlassContentPanel(
                        size: size,
                        controller: controller,
                        onGetStarted: controller.completeOnboarding,
                        onLogIn: controller.completeOnboarding,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryStart,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryStart.opacityColor(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.nights_stay,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
      ),
    );
  }
}

class _GlassContentPanel extends StatelessWidget {
  const _GlassContentPanel({
    required this.size,
    required this.controller,
    required this.onGetStarted,
    required this.onLogIn,
  });

  final Size size;
  final OnboardingController controller;
  final VoidCallback onGetStarted;
  final VoidCallback onLogIn;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: 32,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFF121820).opacityColor(0.6),
            border: Border.all(color: Colors.white.opacityColor(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Your Journey to Better Sleep Starts Here',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Escape into a world of tranquility with curated sounds and personalized sleep environments.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 160,
                child: PageView(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  children: [
                    Obx(
                      () => _FeatureSlide(
                        isActive: controller.currentPageIndex.value == 0,
                        icon: Icons.library_music,
                        title: 'Soothing Sounds',
                        subtitle: 'Curated nature melodies',
                      ),
                    ),
                    Obx(
                      () => _FeatureSlide(
                        isActive: controller.currentPageIndex.value == 1,
                        icon: Icons.tune,
                        title: 'Smart Mixer',
                        subtitle: 'Your custom blend',
                      ),
                    ),
                    Obx(
                      () => _FeatureSlide(
                        isActive: controller.currentPageIndex.value == 2,
                        icon: Icons.timer,
                        title: 'Sleep Timer',
                        subtitle: 'Auto-off for deep rest',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => _PaginationDots(
                  currentIndex: controller.currentPageIndex.value,
                  onDotTap: controller.goToPage,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onGetStarted,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryStart,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: const StadiumBorder(),
                    elevation: 8,
                    shadowColor: AppColors.primaryStart.opacityColor(0.4),
                  ),
                  child: Text(
                    AppStrings.getStarted,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureSlide extends StatefulWidget {
  const _FeatureSlide({
    required this.isActive,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final bool isActive;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  State<_FeatureSlide> createState() => _FeatureSlideState();
}

class _FeatureSlideState extends State<_FeatureSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    if (widget.isActive) _animController.forward();
  }

  @override
  void didUpdateWidget(covariant _FeatureSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryStart.opacityColor(0.2),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.primaryStart.opacityColor(0.4),
                ),
              ),
              child: Icon(widget.icon, color: AppColors.primaryStart, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationDots extends StatelessWidget {
  const _PaginationDots({required this.currentIndex, required this.onDotTap});

  final int currentIndex;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isSelected = index == currentIndex;
        return GestureDetector(
          onTap: () => onDotTap(index),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: isSelected ? 32 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryStart
                    : Colors.white.opacityColor(0.3),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        );
      }),
    );
  }
}
