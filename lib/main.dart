import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/bindings/app_binding.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/services/audio_handler.dart';
import 'core/services/iap_service.dart';
import 'core/themes/app_theme.dart';
import 'data/providers/hive_provider.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final handler = await AudioService.init(
    builder: () => SleepAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'dat.c.sleepheaven.audio',
      androidNotificationChannelName: 'Sleep Heaven',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      notificationColor: AppColors.backgroundDark,
    ),
  );
  Get.put<SleepAudioHandler>(handler, permanent: true);

  // Khởi tạo Hive trước khi chạy app
  final hiveProvider = HiveProvider();
  await hiveProvider.init();
  Get.put<HiveProvider>(hiveProvider, permanent: true);

  // Khởi tạo IAP service – đọc cache offline, lắng nghe purchaseStream
  final iapService = IAPService();
  await iapService.init();
  Get.put<IAPService>(iapService, permanent: true);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => GetMaterialApp(
        title: '${AppStrings.appName} - ${AppStrings.appSubtitle}',
        initialBinding: AppBinding(),
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        getPages: AppPages.pages,
        initialRoute: _getInitialRoute(),
      ),
    );
  }

  String _getInitialRoute() {
    final hive = Get.find<HiveProvider>();
    return hive.hasSeenOnboarding ? Routes.home : Routes.onboarding;
  }
}
