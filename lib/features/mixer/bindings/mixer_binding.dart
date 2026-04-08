import 'package:get/get.dart';

import '../../../core/services/iap_service.dart';
import '../../../data/repositories/local_track_repository.dart';
import '../../local_music/controllers/local_music_controller.dart';
import '../controllers/mixer_controller.dart';

class MixerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MixerController>(() => MixerController());
    Get.lazyPut<LocalMusicController>(
      () => LocalMusicController(
        Get.find<LocalTrackRepository>(),
        Get.find<IAPService>(),
      ),
      fenix: true,
    );
  }
}
