// One customer, with a few numbers calculated from their orders.
class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final int ordersCount;
  final double totalSpent; // only delivered orders

  const CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.ordersCount,
    required this.totalSpent,
  });
}