import 'package:get/get.dart';

class NavigationStateService extends GetxService {
  final RxString currentRoute = ''.obs;

  void updateRoute(String? route) {
    if (route == null || route.isEmpty) {
      return;
    }
    currentRoute.value = route;
  }
}
