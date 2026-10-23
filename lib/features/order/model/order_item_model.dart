// One row of the order_items table (a product inside an order).
class OrderItemModel {
  final String name;
  final double price;
  final int qty;

  const OrderItemModel({
    required this.name,
    required this.price,
    required this.qty,
  });

  double get lineTotal => price * qty;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      name: json['name_snapshot'] as String,
      price: double.parse(json['price_snapshot'].toString()),
      qty: json['qty'] as int,
    );
  }
}