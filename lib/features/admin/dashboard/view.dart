// Admin dashboard: store switch, today's numbers, new orders waiting.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/shared/error_view.dart';
import '../../../core/shared/loading_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_helper.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../auth/controller.dart';
import '../../order/model/order_model.dart';
import '../order/controller.dart';
import '../order/details/view.dart';
import '../order/widget/admin_order_card.dart';
import 'controller.dart';

class AdminDashboardView extends ConsumerWidget {
  const AdminDashboardView({super.key});

  Future<void> _toggleStore(
      BuildContext context,
      WidgetRef ref,
      bool value,
      ) async {
    final error =
    await ref.read(storeOpenControllerProvider.notifier).setOpen(value);
    if (!context.mounted) return;
    if (error != null) {
      showSnack(context, error);
    }
  }

  // Card with the Open / Closed switch
  Widget _storeCard(BuildContext context, WidgetRef ref) {
    final openAsync = ref.watch(storeOpenProvider);
    final saving = ref.watch(storeOpenControllerProvider).isLoading;
    final isOpen = openAsync.value ?? false;
    final canToggle = openAsync.hasValue && !saving;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOpen ? AppColors.successSoft : AppColors.dangerSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: isOpen ? AppColors.success : AppColors.danger,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen ? 'Store is open' : 'Store is closed',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOpen
                      ? 'Customers can place orders'
                      : 'Customers cannot place orders',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isOpen,
            onChanged:
            canToggle ? (value) => _toggleStore(context, ref, value) : null,
          ),
        ],
      ),
    );
  }

  // Big orange card with today's revenue
  Widget _revenueCard(DashboardStats stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payments_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Today's revenue",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                '${AppConstants.currency} ${stats.todayRevenue.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'Delivered orders only',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      WidgetRef ref,
      List<OrderModel> orders,
      ) {
    final stats = calculateStats(orders);

    // Collect the orders that are waiting to be accepted
    final pending = <OrderModel>[];
    for (final order in orders) {
      if (order.status == OrderStatus.placed) {
        pending.add(order);
      }
    }

    // Show at most 5 pending orders
    final pendingCards = <Widget>[];
    for (var i = 0; i < pending.length && i < 5; i++) {
      final order = pending[i];
      pendingCards.add(
        AdminOrderCard(
          order: order,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AdminOrderDetailView(orderId: order.id),
              ),
            );
          },
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _storeCard(context, ref),
        const SizedBox(height: 16),
        _revenueCard(stats),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: "Today's orders",
                value: '${stats.todayOrders}',
                icon: Icons.receipt_long_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Pending',
                value: '${stats.pendingCount}',
                icon: Icons.hourglass_top_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'New orders waiting',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        if (pendingCards.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No new orders right now',
                style: TextStyle(color: AppColors.textLight),
              ),
            ),
          ),
        ...pendingCards,
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: ordersAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: errorText(error),
          onRetry: () => ref.invalidate(adminOrdersProvider),
        ),
        data: (orders) => _buildContent(context, ref, orders),
      ),
    );
  }
}

// Small white card with one number
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 26,
              color: AppColors.textDark,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textLight, fontSize: 13),
          ),
        ],
      ),
    );
  }
}