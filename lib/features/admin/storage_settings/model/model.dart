// The one row of the store_settings table (id = 1), used by the admin.
class AdminStoreSettings {
  final double deliveryFee;
  final double minOrder;
  final String hours;

  const AdminStoreSettings({
    required this.deliveryFee,
    required this.minOrder,
    required this.hours,
  });

  factory AdminStoreSettings.fromJson(Map<String, dynamic> json) {
    return AdminStoreSettings(
      deliveryFee: double.parse((json['delivery_fee'] ?? 0).toString()),
      minOrder: double.parse((json['min_order'] ?? 0).toString()),
      hours: (json['hours'] ?? '') as String,
    );
  }
}