import 'package:get/get.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/sound_model.dart';
import '../../../data/repositories/sound_repository.dart';

class HomeController extends GetxController {
  final SoundRepository _repository = Get.find<SoundRepository>();

  List<CategoryModel> get categories => CategoryModel.all;

  List<SoundModel> getSoundsByCategory(String categoryId) =>
      _repository.getSoundsByCategory(categoryId);

  List<SoundModel> get featuredSounds =>
      _repository.getAllSounds().take(6).toList();

  bool isFavorite(String soundId) => _repository.isFavorite(soundId);

  void toggleFavorite(String soundId) {
    _repository.toggleFavorite(soundId);
    update();
  }
}
