import 'package:get/get.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/sound_model.dart';
import '../../../data/repositories/sound_repository.dart';

class LibraryController extends GetxController {
  final SoundRepository _repository = Get.find<SoundRepository>();

  int selectedTabIndex = 0;

  List<CategoryModel> get categories => CategoryModel.all;

  List<SoundModel> get sounds {
    if (selectedTabIndex == 0) {
      return _repository.getAllSounds();
    }
    if (selectedTabIndex == categories.length + 1) {
      return _repository.getFavorites();
    }
    return _repository.getSoundsByCategory(categories[selectedTabIndex - 1].id);
  }

  bool isFavorite(String soundId) => _repository.isFavorite(soundId);

  void toggleFavorite(String soundId) {
    _repository.toggleFavorite(soundId);
    update();
  }

  void selectTab(int index) {
    selectedTabIndex = index;
    update();
  }
}
