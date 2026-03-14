import 'package:get/get.dart';
import '../../data/providers/hive_provider.dart';
import '../../data/repositories/sound_repository.dart';
import '../services/iap_service.dart';

/// Binding toàn cục - đăng ký các service dùng chung
/// HiveProvider và IAPService đã được put permanent trong main.dart
class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SoundRepository>(
      SoundRepository(
        Get.find<HiveProvider>(),
        Get.find<IAPService>(),
      ),
      permanent: true,
    );
  }
}
