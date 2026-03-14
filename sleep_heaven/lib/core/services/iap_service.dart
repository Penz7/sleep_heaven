import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Product ID phải khớp với Google Play Console và App Store Connect
const String _premiumProductId = 'premium_unlock';

/// Key lưu trạng thái premium trong secure storage
const String _premiumStorageKey = 'premium_unlocked';

/// Service quản lý IAP non-consumable – singleton, sống suốt vòng đời app
class IAPService extends GetxService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  /// Trạng thái premium reactive – đọc sync từ mọi controller
  final RxBool isPremium = false.obs;

  /// Khởi tạo service – gọi trong main.dart trước runApp
  Future<IAPService> init() async {
    // Đọc cache từ secure storage trước – cho phép offline unlock
    final cached = await _storage.read(key: _premiumStorageKey);
    isPremium.value = cached == 'true';

    // Lắng nghe purchase stream suốt vòng đời app
    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (Object e) => debugPrint('[IAPService] purchaseStream error: $e'),
    );

    // Tự động restore nếu có mạng và store available
    final storeAvailable = await _iap.isAvailable();
    if (storeAvailable) {
      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity.any((r) => r != ConnectivityResult.none);
      if (isOnline) {
        await _iap.restorePurchases();
      }
    }

    return this;
  }

  @override
  void onClose() {
    _purchaseSubscription?.cancel();
    super.onClose();
  }

  /// Lấy thông tin sản phẩm từ store (dùng để hiển thị giá thực tế)
  Future<ProductDetails?> getPremiumProduct() async {
    try {
      final response = await _iap.queryProductDetails({_premiumProductId});
      if (response.error != null) {
        debugPrint('[IAPService] queryProductDetails error: ${response.error}');
      }
      if (response.productDetails.isEmpty) return null;
      return response.productDetails.first;
    } catch (e) {
      debugPrint('[IAPService] getPremiumProduct exception: $e');
      return null;
    }
  }

  /// Bắt đầu luồng mua premium
  Future<void> buyPremium() async {
    final product = await getPremiumProduct();
    if (product == null) {
      throw Exception('Không tìm thấy sản phẩm premium trên store.');
    }
    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
    // Kết quả được xử lý bất đồng bộ qua _onPurchaseUpdate
  }

  /// Restore purchase sau khi reinstall (cần mạng)
  Future<void> restorePurchases() async {
    final available = await _iap.isAvailable();
    if (!available) {
      throw Exception('Store không khả dụng. Vui lòng kiểm tra kết nối mạng.');
    }
    await _iap.restorePurchases();
    // Kết quả được xử lý bất đồng bộ qua _onPurchaseUpdate
  }

  /// Xử lý tất cả purchase events từ store
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != _premiumProductId) continue;

      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Lưu vĩnh viễn vào secure storage và cập nhật reactive state
          await _storage.write(key: _premiumStorageKey, value: 'true');
          isPremium.value = true;
          debugPrint('[IAPService] Premium unlocked (${purchase.status.name})');

        case PurchaseStatus.error:
          debugPrint('[IAPService] Purchase error: ${purchase.error?.message}');

        case PurchaseStatus.canceled:
          debugPrint('[IAPService] Purchase canceled by user');

        case PurchaseStatus.pending:
          debugPrint('[IAPService] Purchase pending...');
      }

      // Bắt buộc complete để tránh trạng thái pending mãi mãi
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }
}
