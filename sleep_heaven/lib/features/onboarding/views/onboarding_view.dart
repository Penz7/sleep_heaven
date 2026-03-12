import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              AppColors.primaryEnd,
              AppColors.primaryStart,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: controller.skip,
                  child: Text(AppStrings.skip, style: const TextStyle(color: Colors.white70)),
                ),
              ),
              Expanded(
                child: PageView(
                  children: [
                    _buildSlide(
                      Icons.library_music,
                      'Sound Library',
                      'Browse 100+ relaxing sounds for sleep and focus.',
                    ),
                    _buildSlide(
                      Icons.timer,
                      'Sleep Timer',
                      'Set a timer to fade out and stop playback automatically.',
                    ),
                    _buildSlide(
                      Icons.tune,
                      'Sound Mixer',
                      'Mix up to 3 sounds together for your perfect blend.',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: CustomButton(
                  label: AppStrings.getStarted,
                  onPressed: controller.completeOnboarding,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.white70),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
