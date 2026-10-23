// A model = a Dart class for one row of a table.
class ProductModel {
  final String id;
  final String? categoryId;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final bool inStock;

  const ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.inStock,
  });

  // Builds a ProductModel from the data Supabase sends (a Map).
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      categoryId: json['category_id'] as String?,
      name: json['name'] as String,
      description: (json['description'] ?? '') as String,
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'] as String?,
      inStock: json['in_stock'] as bool,
    );
  }
}