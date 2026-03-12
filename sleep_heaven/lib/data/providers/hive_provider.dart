import 'package:hive_flutter/hive_flutter.dart';

/// Provider quản lý Hive - favorites, settings, premium status
class HiveProvider {
  static const String _favoritesBox = 'favorites';
  static const String _settingsBox = 'settings';
  static const String _favoritesKey = 'favorite_ids';
  static const String _isPremiumKey = 'is_premium';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  Box<dynamic>? _favoritesBoxInstance;
  Box<dynamic>? _settingsBoxInstance;

  Future<void> init() async {
    await Hive.initFlutter();
    _favoritesBoxInstance = await Hive.openBox(_favoritesBox);
    _settingsBoxInstance = await Hive.openBox(_settingsBox);
  }

  List<String> get favoriteIds {
    final raw = _favoritesBoxInstance?.get(_favoritesKey);
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return [];
  }

  set favoriteIds(List<String> ids) {
    _favoritesBoxInstance?.put(_favoritesKey, ids);
  }

  void toggleFavorite(String soundId) {
    final current = favoriteIds.toList();
    if (current.contains(soundId)) {
      current.remove(soundId);
    } else {
      current.add(soundId);
    }
    favoriteIds = current;
  }

  bool isFavorite(String soundId) => favoriteIds.contains(soundId);

  bool get isPremium => _settingsBoxInstance?.get(_isPremiumKey, defaultValue: false) as bool? ?? false;

  set isPremium(bool value) {
    _settingsBoxInstance?.put(_isPremiumKey, value);
  }

  bool get hasSeenOnboarding =>
      _settingsBoxInstance?.get(_hasSeenOnboardingKey, defaultValue: false) as bool? ?? false;

  set hasSeenOnboarding(bool value) {
    _settingsBoxInstance?.put(_hasSeenOnboardingKey, value);
  }
}
