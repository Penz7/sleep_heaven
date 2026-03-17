import 'package:get/get.dart';

import '../../../core/services/iap_service.dart';

class PremiumController extends GetxController {
  final IAPService _iap = Get.find<IAPService>();

  final RxBool isLoading = false.obs;

  /// Đọc trực tiếp từ IAPService – reactive và sync
  bool get isPremium => _iap.isPremium.value;

  /// Bắt đầu luồng mua premium – kết quả unlock xử lý async qua purchaseStream
  Future<void> purchasePremium() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await _iap.buyPremium();
      // purchaseStream callback trong IAPService sẽ tự cập nhật isPremium
      // và lưu vào secure_storage khi store xác nhận
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Restore purchase sau khi reinstall hoặc đổi thiết bị
  Future<void> restorePurchase() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await _iap.restorePurchases();
      // Nếu tìm thấy purchase đã mua, purchaseStream sẽ cập nhật isPremium
      // và hiển thị thông báo thành công
      Get.snackbar(
        'Restore',
        'Checking purchases...',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
