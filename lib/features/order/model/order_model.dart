// One row of the orders table.
import '../../../core/constants/app_constants.dart';

class OrderModel {
  final String id;
  final String status;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final String? notes;
  final DateTime createdAt;
  final Map<String, dynamic> addressSnapshot; // copy of the address at order time

  const OrderModel({
    required this.id,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.notes,
    required this.createdAt,
    required this.addressSnapshot,
  });

  // A short id to show on screen, like "3F9A21BC"
  String get shortId => id.substring(0, 8).toUpperCase();

  String get addressLabel => (addressSnapshot['label'] ?? '') as String;
  String get addressText => (addressSnapshot['full_address'] ?? '') as String;
  // Customer details are saved inside the address snapshot
  String get customerName =>
      (addressSnapshot['customer_name'] ?? '') as String;
  String get customerPhone =>
      (addressSnapshot['customer_phone'] ?? '') as String;

  // The customer may cancel only while the store has not accepted it yet.
  bool get canCancel => status == OrderStatus.placed;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      status: json['status'] as String,
      subtotal: double.parse(json['subtotal'].toString()),
      deliveryFee: double.parse(json['delivery_fee'].toString()),
      total: double.parse(json['total'].toString()),
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      addressSnapshot:
      Map<String, dynamic>.from(json['address_snapshot'] as Map),
    );
  }
}