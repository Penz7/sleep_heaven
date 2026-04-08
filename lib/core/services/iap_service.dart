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

enum IapReliabilityState {
  pending,
  notPurchased,
  purchased,
  restored,
  restoreInconsistent,
  failed,
  offlineRestore,
}

abstract class IapStoreClient {
  Stream<List<PurchaseDetails>> get purchaseStream;
  Future<bool> isAvailable();
  Future<void> restorePurchases();
  Future<void> buyNonConsumable(PurchaseParam purchaseParam);
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers);
  Future<void> completePurchase(PurchaseDetails purchase);
}

class InAppPurchaseStoreClient implements IapStoreClient {
  InAppPurchaseStoreClient(this._iap);
  final InAppPurchase _iap;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  @override
  Future<bool> isAvailable() => _iap.isAvailable();

  @override
  Future<void> restorePurchases() => _iap.restorePurchases();

  @override
  Future<void> buyNonConsumable(PurchaseParam purchaseParam) =>
      _iap.buyNonConsumable(purchaseParam: purchaseParam);

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) =>
      _iap.queryProductDetails(identifiers);

  @override
  Future<void> completePurchase(PurchaseDetails purchase) =>
      _iap.completePurchase(purchase);
}

abstract class ConnectivityClient {
  Future<List<ConnectivityResult>> checkConnectivity();
}

class DefaultConnectivityClient implements ConnectivityClient {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() =>
      Connectivity().checkConnectivity();
}

abstract class SecureStoreClient {
  Future<String?> read({required String key});
  Future<void> write({required String key, required String value});
}

class FlutterSecureStoreClient implements SecureStoreClient {
  const FlutterSecureStoreClient(this._storage);
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);
}

/// Service quản lý IAP non-consumable – singleton, sống suốt vòng đời app
class IAPService extends GetxService {
  IAPService({
    IapStoreClient? storeClient,
    SecureStoreClient? secureStore,
    ConnectivityClient? connectivityClient,
  }) : _storeClient =
           storeClient ?? InAppPurchaseStoreClient(InAppPurchase.instance),
       _secureStore =
           secureStore ??
           const FlutterSecureStoreClient(FlutterSecureStorage()),
       _connectivityClient = connectivityClient ?? DefaultConnectivityClient();

  final IapStoreClient _storeClient;
  final SecureStoreClient _secureStore;
  final ConnectivityClient _connectivityClient;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  /// Trạng thái premium reactive – đọc sync từ mọi controller
  final RxBool isPremium = false.obs;
  final RxBool hasPendingReconciliation = false.obs;
  final RxnString lastRecoverableErrorCode = RxnString();

  /// Chế độ dev – bỏ qua store, force-unlock premium ngay khi khởi động
  bool _devMode = false;
  bool get isDevMode => _devMode;

  /// Khởi tạo service – gọi trong main.dart trước runApp
  /// Truyền [devMode] = true để unlock premium tự động (chỉ dùng khi debug)
  Future<IAPService> init({bool devMode = false}) async {
    _devMode = devMode;

    if (devMode) {
      isPremium.value = true;
      debugPrint('[IAPService] DEV MODE – Premium force-unlocked');
      return this;
    }

    // Đọc cache từ secure storage trước – cho phép offline unlock
    final cached = await _secureStore.read(key: _premiumStorageKey);
    isPremium.value = cached == 'true';

    // Lắng nghe purchase stream suốt vòng đời app
    _purchaseSubscription = _storeClient.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (Object e) =>
          debugPrint('[IAPService] purchaseStream error: $e'),
    );

    // Tự động restore nếu có mạng và store available
    final storeAvailable = await _storeClient.isAvailable();
    if (storeAvailable) {
      final connectivity = await _connectivityClient.checkConnectivity();
      final isOnline = connectivity.any((r) => r != ConnectivityResult.none);
      if (isOnline) {
        await _storeClient.restorePurchases();
      } else {
        hasPendingReconciliation.value = true;
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
      final response = await _storeClient.queryProductDetails({
        _premiumProductId,
      });
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
      throw Exception('Premium product not found in the store.');
    }
    await _storeClient.buyNonConsumable(PurchaseParam(productDetails: product));
    // Kết quả được xử lý bất đồng bộ qua _onPurchaseUpdate
  }

  /// Restore purchase sau khi reinstall (cần mạng)
  Future<void> restorePurchases() async {
    final available = await _storeClient.isAvailable();
    if (!available) {
      throw Exception('Store is not available. Please check your connection.');
    }
    await _storeClient.restorePurchases();
    // Kết quả được xử lý bất đồng bộ qua _onPurchaseUpdate
  }

  Future<void> attemptStartupReconciliation() async {
    final List<ConnectivityResult> connectivity = await _connectivityClient
        .checkConnectivity();
    final bool isOnline = connectivity.any(
      (ConnectivityResult r) => r != ConnectivityResult.none,
    );
    if (!isOnline) {
      hasPendingReconciliation.value = true;
      return;
    }
    hasPendingReconciliation.value = false;
    await restorePurchases();
  }

  Future<IapReliabilityState> applyReliabilityState(
    IapReliabilityState state,
  ) async {
    switch (state) {
      case IapReliabilityState.pending:
        isPremium.value = false;
        hasPendingReconciliation.value = true;
        lastRecoverableErrorCode.value = 'IAP_PENDING';
        return state;
      case IapReliabilityState.notPurchased:
        isPremium.value = false;
        hasPendingReconciliation.value = false;
        lastRecoverableErrorCode.value = null;
        return state;
      case IapReliabilityState.purchased:
      case IapReliabilityState.restored:
        isPremium.value = true;
        hasPendingReconciliation.value = false;
        lastRecoverableErrorCode.value = null;
        await _secureStore.write(key: _premiumStorageKey, value: 'true');
        return state;
      case IapReliabilityState.restoreInconsistent:
        isPremium.value = false;
        hasPendingReconciliation.value = true;
        lastRecoverableErrorCode.value = 'IAP_RESTORE_INCONSISTENT';
        return state;
      case IapReliabilityState.failed:
        isPremium.value = false;
        lastRecoverableErrorCode.value = 'IAP_FAILED';
        return state;
      case IapReliabilityState.offlineRestore:
        isPremium.value = false;
        hasPendingReconciliation.value = true;
        lastRecoverableErrorCode.value = 'IAP_OFFLINE_RESTORE';
        return state;
    }
  }

  /// Xử lý tất cả purchase events từ store
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != _premiumProductId) continue;

      switch (purchase.status) {
        case PurchaseStatus.purchased:
          await applyReliabilityState(IapReliabilityState.purchased);
          debugPrint('[IAPService] Premium unlocked (${purchase.status.name})');
          break;

        case PurchaseStatus.restored:
          if (purchase.verificationData.localVerificationData.isEmpty &&
              purchase.verificationData.serverVerificationData.isEmpty) {
            await applyReliabilityState(IapReliabilityState.restoreInconsistent);
            break;
          }
          await applyReliabilityState(IapReliabilityState.restored);
          debugPrint('[IAPService] Premium unlocked (${purchase.status.name})');
          break;

        case PurchaseStatus.error:
          await applyReliabilityState(IapReliabilityState.failed);
          debugPrint('[IAPService] Purchase error: ${purchase.error?.message}');
          break;

        case PurchaseStatus.canceled:
          debugPrint('[IAPService] Purchase canceled by user');
          break;

        case PurchaseStatus.pending:
          await applyReliabilityState(IapReliabilityState.pending);
          debugPrint('[IAPService] Purchase pending...');
          break;
      }

      // Bắt buộc complete để tránh trạng thái pending mãi mãi
      if (purchase.pendingCompletePurchase) {
        await _storeClient.completePurchase(purchase);
      }
    }
  }
}
