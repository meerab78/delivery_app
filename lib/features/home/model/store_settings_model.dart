// The single row of the store_settings table.
class StoreSettingsModel {
  final bool isOpen;
  final double deliveryFee;
  final double minOrder;
  final String hours;

  const StoreSettingsModel({
    required this.isOpen,
    required this.deliveryFee,
    required this.minOrder,
    required this.hours,
  });

  factory StoreSettingsModel.fromJson(Map<String, dynamic> json) {
    return StoreSettingsModel(
      isOpen: json['is_open'] as bool,
      deliveryFee: double.parse(json['delivery_fee'].toString()),
      minOrder: double.parse(json['min_order'].toString()),
      hours: (json['hours'] ?? '') as String,
    );
  }
}