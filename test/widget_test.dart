import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sleep_heaven/core/bindings/app_binding.dart';
import 'package:sleep_heaven/core/services/iap_service.dart';
import 'package:sleep_heaven/data/providers/hive_provider.dart';
import 'package:sleep_heaven/data/repositories/sound_repository.dart';

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
    final IAPService iapService = IAPService();
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
  });
}
