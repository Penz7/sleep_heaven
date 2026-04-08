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
  @override
  Future<String?> read({required String key}) async => null;

  @override
  Future<void> write({required String key, required String value}) async {}
}

class _FakeConnectivityClient implements ConnectivityClient {
  _FakeConnectivityClient(this.results);
  List<ConnectivityResult> results;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => results;
}

void main() {
  test('offline startup does not grant entitlement and sets pending reconcile', () async {
    final _FakeStoreClient storeClient = _FakeStoreClient();
    final _FakeConnectivityClient connectivityClient =
        _FakeConnectivityClient(<ConnectivityResult>[ConnectivityResult.none]);
    final IAPService service = IAPService(
      storeClient: storeClient,
      secureStore: _FakeStore(),
      connectivityClient: connectivityClient,
    );

    await service.attemptStartupReconciliation();

    expect(service.isPremium.value, isFalse);
    expect(service.hasPendingReconciliation.value, isTrue);
    expect(storeClient.restoreCalls, equals(0));
  });

  test('online transition replays restore and reconciles pending state', () async {
    final _FakeStoreClient storeClient = _FakeStoreClient();
    final _FakeConnectivityClient connectivityClient =
        _FakeConnectivityClient(<ConnectivityResult>[ConnectivityResult.none]);
    final IAPService service = IAPService(
      storeClient: storeClient,
      secureStore: _FakeStore(),
      connectivityClient: connectivityClient,
    );

    await service.attemptStartupReconciliation();
    connectivityClient.results = <ConnectivityResult>[ConnectivityResult.wifi];
    await service.attemptStartupReconciliation();

    expect(service.hasPendingReconciliation.value, isFalse);
    expect(storeClient.restoreCalls, equals(1));
  });

  test('repeated startup restore is idempotent with singleton service', () async {
    final _FakeStoreClient storeClient = _FakeStoreClient();
    final _FakeConnectivityClient connectivityClient =
        _FakeConnectivityClient(<ConnectivityResult>[ConnectivityResult.wifi]);
    final IAPService service = IAPService(
      storeClient: storeClient,
      secureStore: _FakeStore(),
      connectivityClient: connectivityClient,
    );

    await service.attemptStartupReconciliation();
    await service.attemptStartupReconciliation();

    expect(storeClient.restoreCalls, equals(2));
    expect(service.hasPendingReconciliation.value, isFalse);
  });
}
