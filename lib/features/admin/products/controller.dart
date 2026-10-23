// Providers and actions for admin products and categories.
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_helper.dart';
import 'model/admin_category_model.dart';
import 'model/admin_product_model.dart';
import 'repository.dart';

final adminProductsProvider =
FutureProvider.autoDispose<List<AdminProductModel>>((ref) {
  return ref.watch(adminCatalogRepositoryProvider).getProducts();
});

final adminCategoriesProvider =
FutureProvider.autoDispose<List<AdminCategoryModel>>((ref) {
  return ref.watch(adminCatalogRepositoryProvider).getCategories();
});

// All actions return null on success, or the error text.
class AdminCatalogController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  // Add a new product (productId == null) or update an existing one.
  Future<String?> saveProduct({
    String? productId,
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required bool inStock,
    required bool isActive,
    File? newImage,
    String? oldImageUrl,
  }) async {
    state = const AsyncLoading<void>();
    try {
      final repo = ref.read(adminCatalogRepositoryProvider);

      // Keep the old picture, unless the admin picked a new one
      String? imageUrl = oldImageUrl;
      if (newImage != null) {
        imageUrl = await repo.uploadProductImage(newImage);
      }

      final values = <String, dynamic>{
        'name': name,
        'description': description.isEmpty ? null : description,
        'price': price,
        'category_id': categoryId,
        'in_stock': inStock,
        'is_active': isActive,
        'image_url': imageUrl,
      };

      if (productId == null) {
        await repo.addProduct(values);
      } else {
        await repo.updateProduct(productId, values);
      }

      ref.invalidate(adminProductsProvider);
      state = const AsyncData<void>(null);
      return null;
    } catch (error) {
      state = const AsyncData<void>(null);
      return errorText(error);
    }
  }

  // The "In stock" switch on the list
  Future<String?> setInStock(String productId, bool value) async {
    try {
      await ref
          .read(adminCatalogRepositoryProvider)
          .updateProduct(productId, {'in_stock': value});
      ref.invalidate(adminProductsProvider);
      return null;
    } catch (error) {
      return errorText(error);
    }
  }

  // The "Visible" switch on the list (false = hidden from customers)
  Future<String?> setProductActive(String productId, bool value) async {
    try {
      await ref
          .read(adminCatalogRepositoryProvider)
          .updateProduct(productId, {'is_active': value});
      ref.invalidate(adminProductsProvider);
      return null;
    } catch (error) {
      return errorText(error);
    }
  }

  // Add a new category (categoryId == null) or rename an existing one.
  Future<String?> saveCategory({
    String? categoryId,
    required String name,
    required int sortOrder,
  }) async {
    try {
      final repo = ref.read(adminCatalogRepositoryProvider);

      if (categoryId == null) {
        await repo.addCategory({
          'name': name,
          'sort_order': sortOrder,
          'is_active': true,
        });
      } else {
        await repo.updateCategory(categoryId, {
          'name': name,
          'sort_order': sortOrder,
        });
      }

      ref.invalidate(adminCategoriesProvider);
      return null;
    } catch (error) {
      return errorText(error);
    }
  }

  Future<String?> setCategoryActive(String categoryId, bool value) async {
    try {
      await ref
          .read(adminCatalogRepositoryProvider)
          .updateCategory(categoryId, {'is_active': value});
      ref.invalidate(adminCategoriesProvider);
      return null;
    } catch (error) {
      return errorText(error);
    }
  }
}

final adminCatalogControllerProvider =
AsyncNotifierProvider<AdminCatalogController, void>(() {
  return AdminCatalogController();
});