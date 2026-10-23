// Customer home: greeting, store banner, category chips and a product grid.
// (It is the first tab of CustomerShell.)
import 'package:delivery_app/features/home/product%20detail/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/shared/error_view.dart';
import '../../core/shared/loading_view.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/error_helper.dart';
import '../auth/profile/controller.dart';
import '../cart/view.dart';
import '../cart/widget/cart_bar.dart';
import 'controller.dart';
import 'model/product_model.dart';
import 'widget/category_chips.dart';
import 'widget/product_card.dart';
import 'widget/store_banner.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  // The product grid (or a loading / error / empty message).
  Widget _buildProducts(
      BuildContext context,
      WidgetRef ref,
      AsyncValue<List<ProductModel>> products,
      String? selectedId,
      ) {
    return products.when<Widget>(
      loading: () => const SliverToBoxAdapter(
        child: Padding(padding: EdgeInsets.all(48), child: LoadingView()),
      ),
      error: (error, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 48),
          child: ErrorView(
            message: errorText(error),
            onRetry: () => ref.invalidate(productsProvider),
          ),
        ),
      ),
      data: (list) {
        // Keep only the products of the selected category
        final filtered = selectedId == null
            ? list
            : list.where((p) => p.categoryId == selectedId).toList();

        if (filtered.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: Text('No products here yet')),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 256,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final product = filtered[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailView(product: product),
                      ),
                    );
                  },
                );
              },
              childCount: filtered.length,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final categories = ref.watch(categoriesProvider).value ?? [];
    final settings = ref.watch(storeSettingsProvider).value;
    final selectedId = ref.watch(selectedCategoryProvider);
    final profile = ref.watch(profileControllerProvider).value;

    // First word of the name, for the greeting
    final firstName = (profile?.name ?? '').trim().split(' ').first;

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.storeName)),
      // Pull down to refresh everything
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productsProvider);
          ref.invalidate(categoriesProvider);
          ref.invalidate(storeSettingsProvider);
          try {
            await ref.read(productsProvider.future);
          } catch (_) {
            // The error is shown in the grid, so we ignore it here.
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Greeting
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstName.isEmpty ? 'Hello!' : 'Hello, $firstName',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'What would you like to order today?',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
            ),
            if (settings != null)
              SliverToBoxAdapter(child: StoreBanner(settings: settings)),
            SliverToBoxAdapter(
              child: CategoryChips(
                categories: categories,
                selectedId: selectedId,
                onSelected: (id) =>
                    ref.read(selectedCategoryProvider.notifier).select(id),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  'Menu',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            _buildProducts(context, ref, products, selectedId),
          ],
        ),
      ),
      // The orange "View cart" bar (only when the cart is not empty).
      // It sits just above the curved navigation bar.
      bottomNavigationBar: CartBar(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartView()),
          );
        },
      ),
    );
  }
}