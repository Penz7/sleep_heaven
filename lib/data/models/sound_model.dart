/// Model âm thanh
class SoundModel {
  const SoundModel({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.assetPath,
    required this.imagePath,
    this.isPremium = false,
    this.icon = 'default',
  });

  final String id;
  final String title;
  final String categoryId;
  final String assetPath;
  final String imagePath;
  final bool isPremium;
  final String icon;

  SoundModel copyWith({
    String? id,
    String? title,
    String? categoryId,
    String? assetPath,
    String? imagePath,
    bool? isPremium,
    String? icon,
  }) {
    return SoundModel(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      assetPath: assetPath ?? this.assetPath,
      imagePath: imagePath ?? this.imagePath,
      isPremium: isPremium ?? this.isPremium,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'categoryId': categoryId,
    'assetPath': assetPath,
    'imagePath': imagePath,
    'isPremium': isPremium,
    'icon': icon,
  };

  factory SoundModel.fromJson(Map<String, dynamic> json) => SoundModel(
    id: json['id'] as String,
    title: json['title'] as String,
    categoryId: json['categoryId'] as String,
    assetPath: json['assetPath'] as String,
    imagePath: json['imagePath'] as String,
    isPremium: json['isPremium'] as bool? ?? false,
    icon: json['icon'] as String? ?? 'default',
  );
}
