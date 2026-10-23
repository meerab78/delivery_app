// Admin order detail: customer, address, items and the status buttons.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/shared/error_view.dart';
import '../../../../core/shared/loading_view.dart';
import '../../../../core/shared/summary_row.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/data_helper.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../order/model/order_model.dart';
import '../../../order/order_status_helper.dart';
import '../controller.dart';

class AdminOrderDetailView extends ConsumerWidget {
  const AdminOrderDetailView({super.key, required this.orderId});

  final String orderId;

  // White rounded card used for every section
  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: child,
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  // Opens the phone dialer with the customer number
  Future<void> _callPhone(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      showSnack(context, 'Could not open the phone app');
    }
  }

  // Asks "Are you sure?" and returns true if the admin says yes
  Future<bool> _confirm(BuildContext context, String text) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  // Sends the new status to the database (update_order_status RPC)
  Future<void> _changeStatus(
      BuildContext context,
      WidgetRef ref,
      String newStatus, {
        String? confirmText,
      }) async {
    if (confirmText != null) {
      final ok = await _confirm(context, confirmText);
      if (!ok) return;
    }

    final error = await ref
        .read(adminOrderActionProvider.notifier)
        .changeStatus(orderId: orderId, newStatus: newStatus);

    if (!context.mounted) return;
    if (error != null) {
      showSnack(context, error);
    }
  }

  // The big buttons at the bottom
  Widget _buildActions(
      BuildContext context,
      WidgetRef ref,
      OrderModel order,
      bool busy,
      ) {
    // New order: Reject or Accept
    if (order.status == OrderStatus.placed) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: busy
                  ? null
                  : () => _changeStatus(
                context,
                ref,
                OrderStatus.rejected,
                confirmText: 'Reject this order?',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                minimumSize: const Size(0, 52),
                side: const BorderSide(color: AppColors.danger),
              ),
              child: const Text('Reject'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: busy
                  ? null
                  : () => _changeStatus(context, ref, OrderStatus.accepted),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
              child: const Text('Accept'),
            ),
          ),
        ],
      );
    }

    // Other statuses have only ONE next step
    String? nextStatus;
    String buttonText = '';
    String? confirmText;

    if (order.status == OrderStatus.accepted) {
      nextStatus = OrderStatus.preparing;
      buttonText = 'Start preparing';
    } else if (order.status == OrderStatus.preparing) {
      nextStatus = OrderStatus.outForDelivery;
      buttonText = 'Out for delivery';
    } else if (order.status == OrderStatus.outForDelivery) {
      nextStatus = OrderStatus.delivered;
      buttonText = 'Delivered (cash collected)';
      confirmText = 'Did you receive the cash from the customer?';
    }

    // Delivered, rejected or cancelled: nothing more to do
    if (nextStatus == null) {
      return const SizedBox.shrink();
    }

    final status = nextStatus;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: busy
            ? null
            : () => _changeStatus(
          context,
          ref,
          status,
          confirmText: confirmText,
        ),
        style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
        child: Text(buttonText),
      ),
    );
  }

  Widget _statusCard(OrderModel order) {
    return _card(
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusSoftColor(order.status),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon(order.status),
              color: statusColor(order.status),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusLabel(order.status),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: statusColor(order.status),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '#${order.shortId}  •  ${formatDateTime(order.createdAt)}',
                  style: const TextStyle(color: AppColors.textLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _customerCard(BuildContext context, OrderModel order) {
    final name = order.customerName.isEmpty ? 'Customer' : order.customerName;
    final phone = order.customerPhone;

    final children = <Widget>[
      _title('Customer'),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: const TextStyle(color: AppColors.textLight),
                ),
              ],
            ),
          ),
          // Tap to call
          if (phone.isNotEmpty)
            IconButton.filled(
              onPressed: () => _callPhone(context, phone),
              style: IconButton.styleFrom(backgroundColor: AppColors.success),
              icon: const Icon(Icons.call, color: Colors.white),
            ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on_outlined,
              size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              order.addressLabel.isEmpty
                  ? order.addressText
                  : '${order.addressLabel}: ${order.addressText}',
              style: const TextStyle(
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ];

    // Show the note only if the customer wrote one
    final note = order.notes;
    if (note != null && note.isNotEmpty) {
      children.add(const SizedBox(height: 12));
      children.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Note: $note',
            style: const TextStyle(color: AppColors.textDark),
          ),
        ),
      );
    }

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _itemsCard(
      WidgetRef ref,
      OrderModel order,
      AsyncValue<List<Map<String, dynamic>>> itemsAsync,
      ) {
    final children = <Widget>[_title('Items')];

    if (itemsAsync.isLoading) {
      children.add(const LoadingView());
    } else if (itemsAsync.hasError) {
      children.add(
        ErrorView(
          message: errorText(itemsAsync.error!),
          onRetry: () => ref.invalidate(adminOrderItemsProvider(orderId)),
        ),
      );
    } else {
      final items = itemsAsync.value ?? [];
      for (final item in items) {
        final name = item['name_snapshot'].toString();
        final price = double.parse(item['price_snapshot'].toString());
        final qty = int.parse(item['qty'].toString());
        final lineTotal = price * qty;

        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Text(
                  '$qty x',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(color: AppColors.textDark),
                  ),
                ),
                Text(
                  '${AppConstants.currency} ${lineTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    children.add(const Divider(height: 24));
    children.add(SummaryRow(label: 'Subtotal', amount: order.subtotal));
    children.add(SummaryRow(label: 'Delivery fee', amount: order.deliveryFee));
    children.add(SummaryRow(label: 'Total', amount: order.total, bold: true));

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _paymentCard(OrderModel order) {
    final isPaid = order.paymentStatus == 'paid';

    return _card(
      Row(
        children: [
          const Icon(Icons.payments_outlined, color: AppColors.primary),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Cash on Delivery',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isPaid ? AppColors.successSoft : AppColors.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isPaid ? 'Paid' : 'Pending',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: isPaid ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(adminOrderProvider(orderId));
    final itemsAsync = ref.watch(adminOrderItemsProvider(orderId));
    final busy = ref.watch(adminOrderActionProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Order details')),
      body: orderAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: errorText(error),
          onRetry: () => ref.invalidate(adminOrderProvider(orderId)),
        ),
        data: (order) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _statusCard(order),
                    _customerCard(context, order),
                    _itemsCard(ref, order, itemsAsync),
                    _paymentCard(order),
                  ],
                ),
              ),
              // Buttons stay at the bottom
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: _buildActions(context, ref, order, busy),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}