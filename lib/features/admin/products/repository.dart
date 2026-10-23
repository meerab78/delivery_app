// Talks to Supabase for products, categories and product images (admin only).
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/db/supabase_client.dart';
import 'model/admin_category_model.dart';
import 'model/admin_product_model.dart';

class AdminCatalogRepository {
  AdminCatalogRepository(this._client);

  final SupabaseClient _client;

  // ---------- Categories ----------

  Future<List<AdminCategoryModel>> getCategories() async {
    final data =
    await _client.from('categories').select().order('sort_order');

    final list = <AdminCategoryModel>[];
    for (final row in data) {
      list.add(AdminCategoryModel.fromJson(row));
    }
    return list;
  }

  Future<void> addCategory(Map<String, dynamic> values) async {
    await _client.from('categories').insert(values);
  }

  Future<void> updateCategory(String id, Map<String, dynamic> values) async {
    await _client.from('categories').update(values).eq('id', id);
  }

  // ---------- Products ----------

  // The admin sees ALL products, also the hidden ones.
  Future<List<AdminProductModel>> getProducts() async {
    final data = await _client
        .from('products')
        .select()
        .order('created_at', ascending: false);

    final list = <AdminProductModel>[];
    for (final row in data) {
      list.add(AdminProductModel.fromJson(row));
    }
    return list;
  }

  Future<void> addProduct(Map<String, dynamic> values) async {
    await _client.from('products').insert(values);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> values) async {
    await _client.from('products').update(values).eq('id', id);
  }

  // ---------- Images ----------

  // Uploads the picture to the public "product-images" bucket
  // and returns the public link. Only the admin may upload (storage policy).
  Future<String> uploadProductImage(File file) async {
    final parts = file.path.split('.');
    final extension = parts.last.toLowerCase();

    // A unique file name, so old pictures are never overwritten
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';

    String contentType = 'image/jpeg';
    if (extension == 'png') {
      contentType = 'image/png';
    } else if (extension == 'webp') {
      contentType = 'image/webp';
    }

    await _client.storage.from('product-images').upload(
      fileName,
      file,
      fileOptions: FileOptions(contentType: contentType),
    );

    return _client.storage.from('product-images').getPublicUrl(fileName);
  }
}

final adminCatalogRepositoryProvider = Provider<AdminCatalogRepository>((ref) {
  return AdminCatalogRepository(ref.watch(supabaseProvider));
});