// "My orders": every order of this customer, newest first.
// It updates live, so the status chips change by themselves.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/shared/error_view.dart';
import '../../../core/shared/loading_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_helper.dart';
import '../../track_order/view.dart';
import '../controller.dart';
import '../widget/order_card.dart';

class OrderHistoryView extends ConsumerWidget {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(myOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: orders.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: errorText(error),
          onRetry: () => ref.invalidate(myOrdersProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 72, color: AppColors.textGrey),
                    SizedBox(height: 16),
                    Text(
                      'No orders yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your orders will show up here',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final order in list)
                OrderCard(
                  order: order,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrackOrderView(orderId: order.id),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}