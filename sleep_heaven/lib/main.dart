import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/bindings/app_binding.dart';
import 'core/constants/app_strings.dart';
import 'core/themes/app_theme.dart';
import 'data/providers/hive_provider.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Hive trước khi chạy app
  final hiveProvider = HiveProvider();
  await hiveProvider.init();
  Get.put<HiveProvider>(hiveProvider, permanent: true);

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
