// Turns a status like 'out_for_delivery' into a label, message, color and icon.
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

String statusLabel(String status) {
  switch (status) {
    case OrderStatus.placed:
      return 'Order placed';
    case OrderStatus.accepted:
      return 'Accepted';
    case OrderStatus.preparing:
      return 'Preparing';
    case OrderStatus.outForDelivery:
      return 'On the way';
    case OrderStatus.delivered:
      return 'Delivered';
    case OrderStatus.rejected:
      return 'Rejected';
    case OrderStatus.cancelled:
      return 'Cancelled';
    default:
      return status;
  }
}

String statusMessage(String status) {
  switch (status) {
    case OrderStatus.placed:
      return 'Waiting for the store to accept your order';
    case OrderStatus.accepted:
      return 'The store accepted your order';
    case OrderStatus.preparing:
      return 'Your order is being prepared';
    case OrderStatus.outForDelivery:
      return 'Your order is on the way. Keep cash ready.';
    case OrderStatus.delivered:
      return 'Delivered. Enjoy!';
    case OrderStatus.rejected:
      return 'Sorry, the store could not accept this order';
    case OrderStatus.cancelled:
      return 'You cancelled this order';
    default:
      return '';
  }
}

// Green when delivered, red when rejected/cancelled, orange while in progress.
Color statusColor(String status) {
  switch (status) {
    case OrderStatus.delivered:
      return AppColors.success;
    case OrderStatus.rejected:
    case OrderStatus.cancelled:
      return AppColors.danger;
    default:
      return AppColors.primary;
  }
}

Color statusSoftColor(String status) {
  switch (status) {
    case OrderStatus.delivered:
      return AppColors.successSoft;
    case OrderStatus.rejected:
    case OrderStatus.cancelled:
      return AppColors.dangerSoft;
    default:
      return AppColors.primarySoft;
  }
}

IconData statusIcon(String status) {
  switch (status) {
    case OrderStatus.placed:
      return Icons.receipt_long;
    case OrderStatus.accepted:
      return Icons.thumb_up_alt_outlined;
    case OrderStatus.preparing:
      return Icons.soup_kitchen_outlined;
    case OrderStatus.outForDelivery:
      return Icons.delivery_dining;
    case OrderStatus.delivered:
      return Icons.check_circle_outline;
    default:
      return Icons.cancel_outlined;
  }
}