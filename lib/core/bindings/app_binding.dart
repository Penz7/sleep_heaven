import 'package:get/get.dart';
import '../../data/providers/hive_provider.dart';
import '../../data/providers/local_track_provider.dart';
import '../../data/repositories/local_track_repository.dart';
import '../../data/repositories/sound_repository.dart';
import '../../features/mixer/controllers/mixer_controller.dart';
import '../../features/player/controllers/player_controller.dart';
import '../services/iap_service.dart';
import '../services/navigation_state_service.dart';

/// Binding toàn cục - đăng ký các service dùng chung
/// HiveProvider và IAPService đã được put permanent trong main.dart
class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SoundRepository>(
      SoundRepository(Get.find<HiveProvider>(), Get.find<IAPService>()),
      permanent: true,
    );
    Get.put<LocalTrackRepository>(
      LocalTrackRepository(LocalTrackProvider()),
      permanent: true,
    );
    if (!Get.isRegistered<PlayerController>()) {
      Get.put<PlayerController>(PlayerController(), permanent: true);
    }
    if (!Get.isRegistered<MixerController>()) {
      Get.put<MixerController>(MixerController(), permanent: true);
    }
    if (!Get.isRegistered<NavigationStateService>()) {
      Get.put<NavigationStateService>(
        NavigationStateService(),
        permanent: true,
      );
    }
  }
}
