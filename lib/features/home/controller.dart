// Home screen data.
// autoDispose = the data is thrown away when nobody is using it.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'model/category_model.dart';
import 'model/product_model.dart';
import 'model/store_settings_model.dart';
import 'repository.dart';

final productsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) {
  return ref.watch(homeRepositoryProvider).getProducts();
});

final categoriesProvider =
FutureProvider.autoDispose<List<CategoryModel>>((ref) {
  return ref.watch(homeRepositoryProvider).getCategories();
});

final storeSettingsProvider =
FutureProvider.autoDispose<StoreSettingsModel>((ref) {
  return ref.watch(homeRepositoryProvider).getStoreSettings();
});

// Remembers which category chip is selected (null = "All").
class SelectedCategoryController extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? categoryId) {
    state = categoryId;
  }
}

final selectedCategoryProvider =
NotifierProvider<SelectedCategoryController, String?>(
  SelectedCategoryController.new,
);