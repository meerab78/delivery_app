// Full details of one product, with an "Add to cart" button.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/shared/product_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_helper.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../cart/controller.dart';
import '../model/product_model.dart';

class ProductDetailView extends ConsumerWidget {
  const ProductDetailView({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Big picture with a round back button on top
          Stack(
            children: [
              ProductImage(
                imageUrl: product.imageUrl,
                name: product.name,
                height: 300,
                width: double.infinity,
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.textDark,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      money(product.price),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: product.inStock
                            ? AppColors.successSoft
                            : AppColors.dangerSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.inStock ? 'In stock' : 'Sold out',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: product.inStock
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'About this item',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  product.description.isEmpty
                      ? 'No description'
                      : product.description,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: Text(
                product.inStock
                    ? 'Add to cart  •  ${money(product.price)}'
                    : 'Sold out',
              ),
              onPressed: product.inStock
                  ? () {
                ref.read(cartControllerProvider.notifier).add(product);
                showSnack(context, '${product.name} added to cart');
                Navigator.pop(context);
              }
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}