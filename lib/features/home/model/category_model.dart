// One row of the categories table.
class CategoryModel {
  final String id;
  final String name;
  final String? imageUrl;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }
}