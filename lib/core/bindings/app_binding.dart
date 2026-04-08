import 'package:get/get.dart';
import '../../data/providers/hive_provider.dart';
import '../../data/providers/local_track_provider.dart';
import '../../data/repositories/local_track_repository.dart';
import '../../data/repositories/sound_repository.dart';
import '../services/iap_service.dart';

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
  }
}
