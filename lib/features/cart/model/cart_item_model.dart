// One line in the cart: a product + how many.
class CartItemModel {
  final String productId;
  final String name;
  final double price;
  final String? imageUrl;
  final int qty;

  const CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.qty,
  });

  double get lineTotal => price * qty;

  // Makes a copy with a different quantity.
  CartItemModel copyWith({int? qty}) {
    return CartItemModel(
      productId: productId,
      name: name,
      price: price,
      imageUrl: imageUrl,
      qty: qty ?? this.qty,
    );
  }

  // Used to save the cart on the phone.
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'qty': qty,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['product_id'] as String,
      name: json['name'] as String,
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'] as String?,
      qty: json['qty'] as int,
    );
  }
}