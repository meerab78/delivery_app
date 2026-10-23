// The cart. It lives in the app and is also saved on the phone,
// so it is still there after closing and opening the app.
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/model/product_model.dart';
import 'model/cart_item_model.dart';

class CartController extends Notifier<List<CartItemModel>> {
  static const _storageKey = 'cart_items';

  @override
  List<CartItemModel> build() {
    _loadFromPhone(); // load the saved cart in the background
    return [];
  }

  Future<void> _loadFromPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved == null) return;

      final list = jsonDecode(saved) as List;
      state = list
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // If the saved data is broken, we simply start with an empty cart.
    }
  }

  Future<void> _saveToPhone() async {
    final prefs = await SharedPreferences.getInstance();
    final text = jsonEncode(state.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, text);
  }

  // Add a product. If it is already in the cart, increase the quantity.
  void add(ProductModel product) {
    final alreadyInCart = state.any((item) => item.productId == product.id);

    if (alreadyInCart) {
      increase(product.id);
      return;
    }

    state = [
      ...state,
      CartItemModel(
        productId: product.id,
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        qty: 1,
      ),
    ];
    _saveToPhone();
  }

  void increase(String productId) {
    final updated = <CartItemModel>[];
    for (final item in state) {
      if (item.productId == productId) {
        updated.add(item.copyWith(qty: item.qty + 1));
      } else {
        updated.add(item);
      }
    }
    state = updated;
    _saveToPhone();
  }

  void decrease(String productId) {
    final updated = <CartItemModel>[];
    for (final item in state) {
      if (item.productId != productId) {
        updated.add(item);
      } else if (item.qty > 1) {
        updated.add(item.copyWith(qty: item.qty - 1));
      }
      // If qty was 1, we skip it, so the item is removed from the cart.
    }
    state = updated;
    _saveToPhone();
  }

  void clear() {
    state = [];
    _saveToPhone();
  }
}

final cartControllerProvider =
NotifierProvider<CartController, List<CartItemModel>>(
  CartController.new,
);

// Total number of pieces in the cart (for the badge).
final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartControllerProvider);
  return items.fold<int>(0, (sum, item) => sum + item.qty);
});

// Sum of all items (before delivery fee).
final cartSubtotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartControllerProvider);
  return items.fold<double>(0, (sum, item) => sum + item.lineTotal);
});