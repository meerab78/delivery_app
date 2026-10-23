// Live order tracking: status header, progress line, address, items, payment.
// Because it uses a stream, the status changes here by itself.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/shared/error_view.dart';
import '../../core/shared/loading_view.dart';
import '../../core/shared/summary_row.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/data_helper.dart';
import '../../core/utils/error_helper.dart';
import '../../core/utils/money_helper.dart';
import '../../core/utils/snackbar_helper.dart';
import '../order/controller.dart';
import '../order/model/order_model.dart';
import '../order/order_status_helper.dart';
import 'widget/order_timeline.dart';

class TrackOrderView extends ConsumerWidget {
  const TrackOrderView({super.key, required this.orderId});

  final String orderId;

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this order?'),
        content: const Text('You can cancel only before the store accepts it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Yes, cancel',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (yes != true) return;

    final error =
    await ref.read(cancelOrderControllerProvider.notifier).cancel(orderId);

    if (context.mounted) {
      showSnack(context, error ?? 'Order cancelled');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderProvider(orderId));
    final itemsAsync = ref.watch(orderItemsProvider(orderId));
    final isCancelling = ref.watch(cancelOrderControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Track order')),
      body: orderAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: errorText(error),
          onRetry: () => ref.invalidate(orderProvider(orderId)),
        ),
        data: (order) {
          final isProblem = order.status == OrderStatus.rejected ||
              order.status == OrderStatus.cancelled;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatusHeader(order: order),
              const SizedBox(height: 12),

              // The progress line is hidden for rejected / cancelled orders.
              if (!isProblem) ...[
                _InfoCard(
                  title: 'Order progress',
                  child: OrderTimeline(status: order.status),
                ),
                const SizedBox(height: 12),
              ],

              _InfoCard(
                title: 'Delivery address',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.addressLabel,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.addressText,
                            style: const TextStyle(color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              _InfoCard(
                title: 'Items',
                child: itemsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(8),
                    child: Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  error: (error, _) => Text(errorText(error)),
                  data: (items) => Column(
                    children: [
                      for (final item in items)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Text(
                                '${item.qty} ×',
                                style: const TextStyle(
                                  color: AppColors.textGrey,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(item.name)),
                              Text(
                                money(item.lineTotal),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _InfoCard(
                title: 'Payment',
                child: Column(
                  children: [
                    SummaryRow(label: 'Subtotal', amount: order.subtotal),
                    SummaryRow(label: 'Delivery fee', amount: order.deliveryFee),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(),
                    ),
                    SummaryRow(label: 'Total', amount: order.total, bold: true),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.payments_outlined,
                            size: 18, color: AppColors.textGrey),
                        const SizedBox(width: 8),
                        const Text('Cash on Delivery'),
                        const Spacer(),
                        Text(
                          order.paymentStatus == 'paid'
                              ? 'Paid'
                              : 'Pay on delivery',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: order.paymentStatus == 'paid'
                                ? AppColors.success
                                : AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (order.notes != null && order.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoCard(title: 'Your note', child: Text(order.notes!)),
              ],

              // Cancel button: only while the order is still "placed".
              if (order.canCancel) ...[
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed:
                  isCancelling ? null : () => _confirmCancel(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                  ),
                  child: isCancelling
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Cancel order'),
                ),
              ],
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

// The big colored box at the top with the current status.
class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(order.status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: statusSoftColor(order.status),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon(order.status), color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusLabel(order.status),
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(statusMessage(order.status)),
                const SizedBox(height: 6),
                Text(
                  'Order #${order.shortId}  •  ${formatDateTime(order.createdAt)}',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// A white rounded box with a title, used for each section.
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}