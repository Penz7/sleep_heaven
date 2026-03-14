import 'package:get/get.dart';
import '../controllers/mixer_controller.dart';

class MixerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MixerController>(() => MixerController());
  }
}
