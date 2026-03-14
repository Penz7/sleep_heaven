import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/providers/hive_provider.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final HiveProvider _hive = Get.find<HiveProvider>();

  final PageController pageController = PageController();
  final RxInt currentPageIndex = 0.obs;
  Timer? _autoPlayTimer;

  static const int _autoPlayDurationSeconds = 3;

  @override
  void onInit() {
    super.onInit();
    _startAutoPlay();
  }

  @override
  void onClose() {
    _autoPlayTimer?.cancel();
    pageController.dispose();
    super.onClose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(
      const Duration(seconds: _autoPlayDurationSeconds),
      (_) => _goToNextPage(),
    );
  }

  void _goToNextPage() {
    final next = (currentPageIndex.value + 1) % 3;
    goToPage(next);
  }

  void goToPage(int index) {
    if (index == currentPageIndex.value) return;
    currentPageIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    _startAutoPlay(); // Reset timer on manual change
  }

  void onPageChanged(int index) {
    currentPageIndex.value = index;
    _startAutoPlay();
  }

  void completeOnboarding() {
    _hive.hasSeenOnboarding = true;
    Get.offAllNamed(Routes.home);
  }
}
