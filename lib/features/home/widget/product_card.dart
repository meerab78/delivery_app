// One product in the 2-column grid.
// If the product is already in the cart, the + button turns into  [ - 2 + ].
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/shared/product_image.dart';
import '../../../core/shared/qty_stepper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_helper.dart';
import '../../cart/controller.dart';
import '../model/product_model.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product, required this.onTap});

  final ProductModel product;
  final VoidCallback onTap; // open the detail screen

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // How many of THIS product are in the cart right now?
    final qty = ref.watch(cartControllerProvider.select((items) {
      for (final item in items) {
        if (item.productId == product.id) return item.qty;
      }
      return 0;
    }));

    final cart = ref.read(cartControllerProvider.notifier);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ProductImage(
                  imageUrl: product.imageUrl,
                  name: product.name,
                  height: 120,
                  width: double.infinity,
                ),
                if (!product.inStock)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white70,
                      alignment: Alignment.center,
                      child: const Text(
                        'Sold out',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                money(product.price),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (product.inStock)
                          qty == 0
                              ? _AddButton(onTap: () => cart.add(product))
                              : QtyStepper(
                            dense: true,
                            qty: qty,
                            onIncrease: () => cart.increase(product.id),
                            onDecrease: () => cart.decrease(product.id),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// The round orange + button.
class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 34,
          height: 34,
          child: Icon(Icons.add, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}