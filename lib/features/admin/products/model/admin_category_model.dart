// One row of the categories table (used by the admin screens).
class AdminCategoryModel {
  final String id;
  final String name;
  final int sortOrder;
  final bool isActive;

  const AdminCategoryModel({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.isActive,
  });

  factory AdminCategoryModel.fromJson(Map<String, dynamic> json) {
    return AdminCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sortOrder: int.parse((json['sort_order'] ?? 0).toString()),
      isActive: (json['is_active'] ?? true) as bool,
    );
  }
}