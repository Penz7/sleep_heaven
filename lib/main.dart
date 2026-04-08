import 'package:audio_service/audio_service.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app/bootstrap/degraded_boot_notice.dart';
import 'core/bindings/app_binding.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/config/feature_flag_service.dart';
import 'core/errors/domain_error.dart';
import 'core/observability/telemetry_config.dart';
import 'core/observability/telemetry_provider.dart';
import 'core/observability/telemetry_service.dart';
import 'core/services/audio_handler.dart';
import 'core/services/iap_service.dart';
import 'core/startup/startup_coordinator.dart';
import 'core/startup/startup_result.dart';
import 'core/themes/app_theme.dart';
import 'data/providers/hive_provider.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

class BootState extends GetxService {
  BootState({required this.result});
  final StartupResult result;
}

List<StartupStepConfig> buildStartupSteps(
  TelemetryService telemetryService, {
  AssetBundle? featureFlagBundle,
  String featureFlagAssetPath = FeatureFlagService.defaultAssetPath,
}) {
  return <StartupStepConfig>[
    StartupStepConfig(
      name: 'audio_handler',
      domain: DomainErrorDomain.audio,
      isCritical: true,
      action: () async {
        final SleepAudioHandler handler = await AudioService.init(
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
      },
    ),
    StartupStepConfig(
      name: 'storage',
      domain: DomainErrorDomain.storage,
      isCritical: true,
      action: () async {
        final HiveProvider hiveProvider = HiveProvider();
        await hiveProvider.init();
        Get.put<HiveProvider>(hiveProvider, permanent: true);
      },
    ),
    StartupStepConfig(
      name: 'feature_flags',
      domain: DomainErrorDomain.startup,
      isCritical: false,
      action: () async {
        final FeatureFlagService featureFlagService =
            await FeatureFlagService.loadFromAsset(
              bundle: featureFlagBundle,
              assetPath: featureFlagAssetPath,
            );
        Get.put<FeatureFlagService>(featureFlagService, permanent: true);
      },
    ),
    StartupStepConfig(
      name: 'iap',
      domain: DomainErrorDomain.iap,
      isCritical: false,
      action: () async {
        const bool kDevMode = bool.fromEnvironment(
          'DEV_MODE',
          defaultValue: false,
        );
        final IAPService iapService = IAPService();
        await iapService.init(devMode: kDevMode);
        Get.put<IAPService>(iapService, permanent: true);
      },
    ),
  ];
}

void configureGlobalErrorHandlers(TelemetryService telemetryService) {
  FlutterError.onError = (FlutterErrorDetails details) {
    telemetryService.capture(
      DomainError(
        domain: DomainErrorDomain.startup,
        severity: DomainErrorSeverity.fatal,
        code: 'FLUTTER_ERROR',
        message: 'Unhandled Flutter framework error.',
        cause: details.exception,
        stackTrace: details.stack,
      ),
    );
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    telemetryService.capture(
      DomainError(
        domain: DomainErrorDomain.startup,
        severity: DomainErrorSeverity.fatal,
        code: 'PLATFORM_ERROR',
        message: 'Unhandled platform error.',
        cause: error,
        stackTrace: stackTrace,
      ),
    );
    return true;
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final TelemetryService telemetryService = TelemetryService(
    provider: const SentryTelemetryProvider(),
    config: TelemetryConfig.fromEnvironment(),
  );
  configureGlobalErrorHandlers(telemetryService);
  Get.put<TelemetryService>(telemetryService, permanent: true);

  final StartupCoordinator coordinator = StartupCoordinator(
    telemetryService: telemetryService,
    steps: buildStartupSteps(telemetryService),
  );
  final StartupResult startupResult = await coordinator.run();
  Get.put<BootState>(BootState(result: startupResult), permanent: true);

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
    final BootState bootState = Get.find<BootState>();
    if (bootState.result.isFatal) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(bootState.result.message ?? 'Startup failed.'),
          ),
        ),
      );
    }
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        final GetMaterialApp app = GetMaterialApp(
          title: '${AppStrings.appName} - ${AppStrings.appSubtitle}',
          initialBinding: AppBinding(),
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          getPages: AppPages.pages,
          initialRoute: _getInitialRoute(),
          builder: (BuildContext context, Widget? routedChild) {
            final Widget body = routedChild ?? const SizedBox.shrink();
            if (!bootState.result.isDegraded) {
              return body;
            }
            return Stack(
              children: <Widget>[
                body,
                Align(
                  alignment: Alignment.topCenter,
                  child: DegradedBootNotice(
                    message:
                        bootState.result.message ?? 'Some services degraded.',
                  ),
                ),
              ],
            );
          },
        );
        return app;
      },
    );
  }

  String _getInitialRoute() {
    final hive = Get.find<HiveProvider>();
    return hive.hasSeenOnboarding ? Routes.home : Routes.onboarding;
  }
}
