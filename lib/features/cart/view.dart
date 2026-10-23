// The cart screen: items, totals and the checkout button.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/shared/summary_row.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/money_helper.dart';
import '../home/controller.dart';
import 'checkout/view.dart';
import 'controller.dart';
import 'widget/cart_item_tile.dart';

class CartView extends ConsumerWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartControllerProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final settings = ref.watch(storeSettingsProvider).value;
    final cart = ref.read(cartControllerProvider.notifier);

    final deliveryFee = settings?.deliveryFee ?? 0;
    final minOrder = settings?.minOrder ?? 0;
    final belowMinimum = subtotal < minOrder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My cart'),
        actions: [
          if (items.isNotEmpty)
            TextButton(onPressed: cart.clear, child: const Text('Clear')),
        ],
      ),
      body: items.isEmpty
          ? _EmptyCart(onBrowse: () => Navigator.pop(context))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final item in items)
            CartItemTile(
              item: item,
              onIncrease: () => cart.increase(item.productId),
              onDecrease: () => cart.decrease(item.productId),
            ),
        ],
      ),
      // Summary + checkout button.
      // NOTE: these numbers are only a preview.
      // The REAL total is calculated by the database in place_order().
      bottomNavigationBar: items.isEmpty
          ? null
          : Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SummaryRow(label: 'Subtotal', amount: subtotal),
              SummaryRow(label: 'Delivery fee', amount: deliveryFee),
              const Divider(height: 20),
              SummaryRow(
                label: 'Total',
                amount: subtotal + deliveryFee,
                bold: true,
              ),
              if (belowMinimum)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Add ${money(minOrder - subtotal)} more to order (minimum ${money(minOrder)})',
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: belowMinimum
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CheckoutView(),
                      ),
                    );
                  },
                  child: const Text('Proceed to checkout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Shown when there is nothing in the cart.
class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 72,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text(
              'Add something tasty from the menu',
              style: TextStyle(color: AppColors.textLight),
            ),
            const SizedBox(height: 24),
            OutlinedButton(onPressed: onBrowse, child: const Text('Browse menu')),
          ],
        ),
      ),
    );
  }
}