import 'package:get/get.dart';

import '../../../core/services/iap_service.dart';
import '../../../data/repositories/local_track_repository.dart';
import '../controllers/local_music_controller.dart';

class LocalMusicBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocalMusicController>(
      () => LocalMusicController(
        Get.find<LocalTrackRepository>(),
        Get.find<IAPService>(),
      ),
    );
  }
}
