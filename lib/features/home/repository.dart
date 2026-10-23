// Talks to Supabase for the customer home screen.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/db/supabase_client.dart';
import 'model/category_model.dart';
import 'model/product_model.dart';
import 'model/store_settings_model.dart';

class HomeRepository {
  HomeRepository(this._client);

  final SupabaseClient _client;

  // RLS already hides inactive products from customers.
  Future<List<ProductModel>> getProducts() async {
    final data = await _client.from('products').select().order('name');
    return data.map((row) => ProductModel.fromJson(row)).toList();
  }

  Future<List<CategoryModel>> getCategories() async {
    final data = await _client.from('categories').select().order('sort_order');
    return data.map((row) => CategoryModel.fromJson(row)).toList();
  }

  // store_settings always has exactly one row (id = 1).
  Future<StoreSettingsModel> getStoreSettings() async {
    final data =
    await _client.from('store_settings').select().eq('id', 1).single();
    return StoreSettingsModel.fromJson(data);
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.watch(supabaseProvider));
});