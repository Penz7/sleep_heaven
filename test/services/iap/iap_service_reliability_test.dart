@Tags(<String>['fast'])
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sleep_heaven/core/services/iap_service.dart';

class _FakeStoreClient implements IapStoreClient {
  int restoreCalls = 0;
  @override
  Stream<List<PurchaseDetails>> get purchaseStream =>
      const Stream<List<PurchaseDetails>>.empty();

  @override
  Future<void> buyNonConsumable(PurchaseParam purchaseParam) async {}

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) {
    return Future<ProductDetailsResponse>.value(
      ProductDetailsResponse(
        productDetails: const <ProductDetails>[],
        notFoundIDs: const <String>[],
        error: null,
      ),
    );
  }

  @override
  Future<void> restorePurchases() async {
    restoreCalls += 1;
  }
}

class _FakeStore implements SecureStoreClient {
  final Map<String, String> values = <String, String>{};
  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}

class _FakeConnectivityClient implements ConnectivityClient {
  _FakeConnectivityClient(this.results);
  List<ConnectivityResult> results;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => results;
}

void main() {
  group('IAP reliability state matrix', () {
    test('not_purchased keeps entitlement false', () async {
      final IAPService service = IAPService(
        storeClient: _FakeStoreClient(),
        secureStore: _FakeStore(),
        connectivityClient: _FakeConnectivityClient(
          <ConnectivityResult>[ConnectivityResult.wifi],
        ),
      );
      await service.applyReliabilityState(IapReliabilityState.notPurchased);
      expect(service.isPremium.value, isFalse);
    }, timeout: const Timeout(Duration(seconds: 5)));

    test('purchased sets entitlement true and persists cache', () async {
      final _FakeStore store = _FakeStore();
      final IAPService service = IAPService(
        storeClient: _FakeStoreClient(),
        secureStore: store,
        connectivityClient: _FakeConnectivityClient(
          <ConnectivityResult>[ConnectivityResult.wifi],
        ),
      );
      await service.applyReliabilityState(IapReliabilityState.purchased);
      expect(service.isPremium.value, isTrue);
      expect(store.values['premium_unlocked'], equals('true'));
    }, timeout: const Timeout(Duration(seconds: 5)));

    test('restored remains idempotent across duplicate events', () async {
      final IAPService service = IAPService(
        storeClient: _FakeStoreClient(),
        secureStore: _FakeStore(),
        connectivityClient: _FakeConnectivityClient(
          <ConnectivityResult>[ConnectivityResult.wifi],
        ),
      );
      await service.applyReliabilityState(IapReliabilityState.restored);
      await service.applyReliabilityState(IapReliabilityState.restored);
      expect(service.isPremium.value, isTrue);
    }, timeout: const Timeout(Duration(seconds: 5)));

    test('failed keeps safe state and emits recoverable signal', () async {
      final IAPService service = IAPService(
        storeClient: _FakeStoreClient(),
        secureStore: _FakeStore(),
        connectivityClient: _FakeConnectivityClient(
          <ConnectivityResult>[ConnectivityResult.wifi],
        ),
      );
      await service.applyReliabilityState(IapReliabilityState.failed);
      expect(service.isPremium.value, isFalse);
      expect(service.lastRecoverableErrorCode.value, equals('IAP_FAILED'));
    }, timeout: const Timeout(Duration(seconds: 5)));

    test('offline_restore marks pending reconciliation', () async {
      final IAPService service = IAPService(
        storeClient: _FakeStoreClient(),
        secureStore: _FakeStore(),
        connectivityClient: _FakeConnectivityClient(
          <ConnectivityResult>[ConnectivityResult.none],
        ),
      );
      await service.applyReliabilityState(IapReliabilityState.offlineRestore);
      expect(service.isPremium.value, isFalse);
      expect(service.hasPendingReconciliation.value, isTrue);
    }, timeout: const Timeout(Duration(seconds: 5)));
  });
}
