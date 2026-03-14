import 'package:get/get.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/sound_model.dart';
import '../../../data/repositories/sound_repository.dart';

class LibraryController extends GetxController {
  final SoundRepository _repository = Get.find<SoundRepository>();

  int selectedTabIndex = 0;

  List<CategoryModel> get categories => CategoryModel.all;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String) {
      _focusCategoryById(args);
    }
  }

  /// Focus tab by category id (from home navigation)
  void _focusCategoryById(String categoryId) {
    final index = categories.indexWhere((c) => c.id == categoryId);
    if (index >= 0) {
      selectTab(index + 1); // +1 because index 0 is "All"
    }
  }

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
