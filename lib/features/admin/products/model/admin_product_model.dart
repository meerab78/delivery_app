// One row of the products table (used by the admin screens).
class AdminProductModel {
  final String id;
  final String? categoryId;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final bool inStock;
  final bool isActive; // false = hidden (soft deleted)

  const AdminProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.inStock,
    required this.isActive,
  });

  factory AdminProductModel.fromJson(Map<String, dynamic> json) {
    return AdminProductModel(
      id: json['id'] as String,
      categoryId: json['category_id'] as String?,
      name: json['name'] as String,
      description: (json['description'] ?? '') as String,
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'] as String?,
      inStock: (json['in_stock'] ?? true) as bool,
      isActive: (json['is_active'] ?? true) as bool,
    );
  }
}