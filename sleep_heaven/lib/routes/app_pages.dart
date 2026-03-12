import 'package:get/get.dart';
import '../features/home/bindings/home_binding.dart';
import '../features/home/views/home_view.dart';
import '../features/library/bindings/library_binding.dart';
import '../features/library/views/library_view.dart';
import '../features/mixer/bindings/mixer_binding.dart';
import '../features/mixer/views/mixer_view.dart';
import '../features/onboarding/bindings/onboarding_binding.dart';
import '../features/onboarding/views/onboarding_view.dart';
import '../features/player/bindings/player_binding.dart';
import '../features/player/views/player_view.dart';
import '../features/premium/bindings/premium_binding.dart';
import '../features/premium/views/premium_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.library,
      page: () => const LibraryView(),
      binding: LibraryBinding(),
    ),
    GetPage(
      name: Routes.player,
      page: () => const PlayerView(),
      binding: PlayerBinding(),
    ),
    GetPage(
      name: Routes.mixer,
      page: () => const MixerView(),
      binding: MixerBinding(),
    ),
    GetPage(
      name: Routes.premium,
      page: () => const PremiumView(),
      binding: PremiumBinding(),
    ),
  ];
}
