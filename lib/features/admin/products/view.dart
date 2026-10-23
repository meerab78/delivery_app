// Admin products list (compact rows).
import 'package:delivery_app/features/admin/products/widgets/admin_product_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/shared/add_fab.dart';
import '../../../core/shared/error_view.dart';
import '../../../core/shared/loading_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_helper.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../categories/view.dart';
import 'controller.dart';
import 'form/view.dart';
import 'model/admin_category_model.dart';
import 'model/admin_product_model.dart';
class AdminProductsView extends ConsumerWidget {
  const AdminProductsView({super.key});

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(adminProductsProvider);
    final categoriesAsync = ref.watch(adminCategoriesProvider);

    // We use hasValue, so the list does not flash a spinner
    // every time a switch is changed.
    if (productsAsync.hasError && !productsAsync.hasValue) {
      return ErrorView(
        message: errorText(productsAsync.error!),
        onRetry: () => ref.invalidate(adminProductsProvider),
      );
    }
    if (!productsAsync.hasValue) {
      return const LoadingView();
    }

    final products = productsAsync.value ?? <AdminProductModel>[];

    if (products.isEmpty) {
      return const Center(
        child: Text(
          'No products yet. Tap "Add product".',
          style: TextStyle(color: AppColors.textLight),
        ),
      );
    }

    // category id -> category name
    final categoryNames = <String, String>{};
    final categories = categoriesAsync.value ?? <AdminCategoryModel>[];
    for (final category in categories) {
      categoryNames[category.id] = category.name;
    }

    return ListView.builder(
      // Extra space at the bottom so the button does not cover the last row
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final categoryName = categoryNames[product.categoryId] ?? 'No category';

        return AdminProductTile(
          product: product,
          categoryName: categoryName,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductFormView(product: product),
              ),
            );
          },
          onInStockChanged: (value) async {
            final error = await ref
                .read(adminCatalogControllerProvider.notifier)
                .setInStock(product.id, value);
            if (!context.mounted) return;
            if (error != null) {
              showSnack(context, error);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            tooltip: 'Categories',
            icon: const Icon(Icons.category_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminCategoriesView()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: AddFab(
        label: 'Add product',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProductFormView()),
          );
        },
      ),
      body: _buildBody(context, ref),
    );
  }
}