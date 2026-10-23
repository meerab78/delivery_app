// Small values used in many places.
class AppConstants {
  static const String currency = 'Rs';
  static const String storeName = 'My Store';
}

// The same status names we use in the database.
class OrderStatus {
  static const String placed = 'placed';
  static const String accepted = 'accepted';
  static const String preparing = 'preparing';
  static const String outForDelivery = 'out_for_delivery';
  static const String delivered = 'delivered';
  static const String rejected = 'rejected';
  static const String cancelled = 'cancelled';
}