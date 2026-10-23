// Reads all customers and their order numbers.
// Only an admin can read other people's profiles and orders (RLS).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/db/supabase_client.dart';
import 'model/customer_model.dart';

class CustomersRepository {
  CustomersRepository(this._client);

  final SupabaseClient _client;

  Future<List<CustomerModel>> getCustomers() async {
    final profiles = await _client
        .from('profiles')
        .select('id, name, phone, created_at')
        .eq('role', 'customer')
        .order('created_at', ascending: false);

    final orders = await _client.from('orders').select('user_id, total, status');

    // Count the orders and add up the money for each customer.
    final Map<String, int> counts = {};
    final Map<String, double> spent = {};

    for (final row in orders) {
      final userId = row['user_id'] as String;
      counts[userId] = (counts[userId] ?? 0) + 1;

      if (row['status'] == 'delivered') {
        final total = double.parse(row['total'].toString());
        spent[userId] = (spent[userId] ?? 0) + total;
      }
    }

    final List<CustomerModel> customers = [];
    for (final row in profiles) {
      final id = row['id'] as String;
      customers.add(
        CustomerModel(
          id: id,
          name: (row['name'] ?? '') as String,
          phone: (row['phone'] ?? '') as String,
          ordersCount: counts[id] ?? 0,
          totalSpent: spent[id] ?? 0,
        ),
      );
    }
    return customers;
  }
}

final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  return CustomersRepository(ref.watch(supabaseProvider));
});