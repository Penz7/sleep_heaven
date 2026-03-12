import 'package:get/get.dart';
import '../../data/providers/hive_provider.dart';
import '../../data/repositories/sound_repository.dart';

/// Binding toàn cục - đăng ký các service dùng chung (HiveProvider đã được put trong main)
class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SoundRepository>(SoundRepository(Get.find<HiveProvider>()), permanent: true);
  }
}
