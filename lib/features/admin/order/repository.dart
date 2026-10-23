// Talks to Supabase for the admin orders screens.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/db/supabase_client.dart';
import '../../order/model/order_model.dart';

class AdminOrdersRepository {
  AdminOrdersRepository(this._client);

  final SupabaseClient _client;

  // LIVE list of ALL orders, newest first.
  // RLS allows this only for the admin.
  Stream<List<OrderModel>> watchAllOrders() {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows.map((row) => OrderModel.fromJson(row)).toList());
  }

  // Items of one order (name_snapshot, price_snapshot, qty)
  Future<List<Map<String, dynamic>>> getOrderItems(String orderId) async {
    final data =
    await _client.from('order_items').select().eq('order_id', orderId);
    return List<Map<String, dynamic>>.from(data);
  }
}

final adminOrdersRepositoryProvider = Provider<AdminOrdersRepository>((ref) {
  return AdminOrdersRepository(ref.watch(supabaseProvider));
});