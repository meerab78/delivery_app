// One order card in the admin list.
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/data_helper.dart';
import '../../../order/model/order_model.dart';
import '../../../order/order_status_helper.dart';

class AdminOrderCard extends StatelessWidget {
  const AdminOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  final OrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isNew = order.status == OrderStatus.placed;
    final name = order.customerName.isEmpty ? 'Customer' : order.customerName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          // New orders get an orange border so the admin notices them
          side: BorderSide(
            color: isNew ? AppColors.primary : Colors.black12,
            width: isNew ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order number + status badge
                Row(
                  children: [
                    Text(
                      '#${order.shortId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusSoftColor(order.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLabel(order.status),
                        style: TextStyle(
                          color: statusColor(order.status),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Customer name
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 18, color: AppColors.textLight),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Address
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 18, color: AppColors.textLight),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.addressText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textLight),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Time + total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDateTime(order.createdAt),
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${AppConstants.currency} ${order.total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}