import 'package:get/get.dart';
import '../../../data/providers/hive_provider.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final HiveProvider _hive = Get.find<HiveProvider>();

  void completeOnboarding() {
    _hive.hasSeenOnboarding = true;
    Get.offAllNamed(Routes.home);
  }

  void skip() => completeOnboarding();
}
