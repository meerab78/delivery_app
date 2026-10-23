// Admin orders board: LIVE list with status filters.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/shared/error_view.dart';
import '../../../core/shared/loading_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_helper.dart';
import '../../order/model/order_model.dart';
import '../../order/order_status_helper.dart';
import 'controller.dart';
import 'details/view.dart';
import 'widget/admin_order_card.dart';

class AdminOrdersView extends ConsumerStatefulWidget {
  const AdminOrdersView({super.key});

  @override
  ConsumerState<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends ConsumerState<AdminOrdersView> {
  // null means "All"
  String? _filter;

  // The filter chips, in order
  final List<String?> _filters = [
    null,
    OrderStatus.placed,
    OrderStatus.accepted,
    OrderStatus.preparing,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
    OrderStatus.rejected,
    OrderStatus.cancelled,
  ];

  Widget _buildChips() {
    final chips = <Widget>[];

    for (final f in _filters) {
      final selected = _filter == f;
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(f == null ? 'All' : statusLabel(f)),
            selected: selected,
            showCheckmark: false,
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) {
              setState(() {
                _filter = f;
              });
            },
          ),
        ),
      );
    }

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: chips,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: Column(
        children: [
          _buildChips(),
          Expanded(
            child: ordersAsync.when(
              loading: () => const LoadingView(),
              error: (error, _) => ErrorView(
                message: errorText(error),
                onRetry: () => ref.invalidate(adminOrdersProvider),
              ),
              data: (orders) {
                // Keep only the orders that match the selected filter
                final shown = <OrderModel>[];
                for (final order in orders) {
                  if (_filter == null || order.status == _filter) {
                    shown.add(order);
                  }
                }

                if (shown.isEmpty) {
                  return const Center(
                    child: Text(
                      'No orders here',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: shown.length,
                  itemBuilder: (context, index) {
                    final order = shown[index];
                    return AdminOrderCard(
                      order: order,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminOrderDetailView(orderId: order.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}