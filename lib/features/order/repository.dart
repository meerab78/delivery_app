// Talks to Supabase for orders: place, list, live updates, cancel.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/db/supabase_client.dart';
import '../cart/model/cart_item_model.dart';
import 'model/order_item_model.dart';
import 'model/order_model.dart';

class OrderRepository {
  OrderRepository(this._client);

  final SupabaseClient _client;

  // We send ONLY product ids and quantities.
  // The database finds the real prices and calculates the total itself.
  // Returns the id of the new order.
  Future<String> placeOrder({
    required String addressId,
    required List<CartItemModel> items,
    String? notes,
  }) async {
    final result = await _client.rpc('place_order', params: {
      'p_address_id': addressId,
      'p_items': items
          .map((item) => {'product_id': item.productId, 'qty': item.qty})
          .toList(),
      'p_notes': (notes == null || notes.isEmpty) ? null : notes,
    });

    return result as String;
  }

  // LIVE list of my orders, newest first.
  // A "stream" sends a new list every time something changes in the database.
  Stream<List<OrderModel>> watchMyOrders() {
    final userId = _client.auth.currentUser!.id;

    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map((row) => OrderModel.fromJson(row)).toList());
  }

  // LIVE updates of ONE order (used by the tracking screen).
  Stream<OrderModel> watchOrder(String orderId) {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .where((rows) => rows.isNotEmpty)
        .map((rows) => OrderModel.fromJson(rows.first));
  }

  // The items inside an order (they never change, so we load them once).
  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    final data =
    await _client.from('order_items').select().eq('order_id', orderId);
    return data.map((row) => OrderItemModel.fromJson(row)).toList();
  }

  // The database checks who may do what (see update_order_status()).
  Future<void> updateStatus({
    required String orderId,
    required String newStatus,
  }) async {
    await _client.rpc('update_order_status', params: {
      'p_order_id': orderId,
      'p_new_status': newStatus,
    });
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(supabaseProvider));
});