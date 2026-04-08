@Tags(<String>['fast'])library;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sleep_heaven/core/bindings/app_binding.dart';
import 'package:sleep_heaven/core/services/iap_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sleep_heaven/data/providers/hive_provider.dart';
import 'package:sleep_heaven/data/repositories/sound_repository.dart';

class _FakeIapStoreClient implements IapStoreClient {
  @override
  Stream<List<PurchaseDetails>> get purchaseStream => Stream<List<PurchaseDetails>>.empty();

  @override
  Future<void> buyNonConsumable(PurchaseParam purchaseParam) async {}

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) async {
    return ProductDetailsResponse(
      productDetails: <ProductDetails>[],
      notFoundIDs: <String>[],
      error: null,
    );
  }

  @override
  Future<void> restorePurchases() async {}
}

class _FakeSecureStoreClient implements SecureStoreClient {
  @override
  Future<String?> read({required String key}) async => null;

  @override
  Future<void> write({required String key, required String value}) async {}
}

class _FakeConnectivityClient implements ConnectivityClient {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return <ConnectivityResult>[ConnectivityResult.none];
  }
}

void main() {
  late Directory tempDocsDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDocsDir = Directory.systemTemp.createTempSync('sleep_heaven_hive_test');

    const MethodChannel pathProviderChannel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (MethodCall call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return tempDocsDir.path;
      }
      return null;
    });
  });

  tearDownAll(() {
    const MethodChannel pathProviderChannel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (tempDocsDir.existsSync()) {
      tempDocsDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    await Hive.initFlutter();
    final HiveProvider hiveProvider = HiveProvider();
    await hiveProvider.init();
    Get.put<HiveProvider>(hiveProvider, permanent: true);
    final IAPService iapService = IAPService(
      storeClient: _FakeIapStoreClient(),
      secureStore: _FakeSecureStoreClient(),
      connectivityClient: _FakeConnectivityClient(),
    );
    await iapService.init(devMode: true);
    Get.put<IAPService>(iapService, permanent: true);
  });

  tearDown(() async {
    Get.reset();
    await Hive.close();
  });

  testWidgets('AppBinding resolves after main-style Get.put bootstrap', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialBinding: AppBinding(),
        home: const Scaffold(
          body: Center(child: Text('smoke')),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('smoke'), findsOneWidget);
    expect(Get.isRegistered<SoundRepository>(), isTrue);
    expect(Get.find<SoundRepository>(), isNotNull);
  }, timeout: const Timeout(Duration(seconds: 10)));
}

