import 'package:get/get.dart';

import '../../../data/providers/hive_provider.dart';

class PremiumController extends GetxController {
  final HiveProvider _hive = Get.find<HiveProvider>();

  final RxBool isLoading = false.obs;

  bool get isPremium => _hive.isPremium;

  Future<void> purchasePremium() async {
    isLoading.value = true;
    try {
      // TODO: Implement in_app_purchase
      await Future.delayed(const Duration(seconds: 1));
      _hive.isPremium = true;
      Get.back();
      Get.snackbar('Success', 'Premium unlocked!');
    } catch (e) {
      Get.snackbar('Error', 'Purchase failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> restorePurchase() async {
    isLoading.value = true;
    try {
      // TODO: Implement restore
      await Future.delayed(const Duration(seconds: 1));
      _hive.isPremium = true;
      Get.back();
      Get.snackbar('Success', 'Purchase restored!');
    } catch (e) {
      Get.snackbar('Error', 'Restore failed: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
