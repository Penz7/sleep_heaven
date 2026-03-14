/// Model danh mục âm thanh
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  final String id;
  final String name;
  final String icon;

  static const List<CategoryModel> all = [
    CategoryModel(id: 'rain', name: 'Rain', icon: 'rain'),
    CategoryModel(id: 'white_noise', name: 'White Noise', icon: 'white_noise'),
    CategoryModel(id: 'baby', name: 'Baby', icon: 'baby'),
    CategoryModel(id: 'nature', name: 'Nature', icon: 'nature'),
  ];
}
