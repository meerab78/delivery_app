// Shows if the store is open or closed, and the delivery fee.
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_helper.dart';
import '../model/store_settings_model.dart';

class StoreBanner extends StatelessWidget {
  const StoreBanner({super.key, required this.settings});

  final StoreSettingsModel settings;

  @override
  Widget build(BuildContext context) {
    final isOpen = settings.isOpen;
    final color = isOpen ? AppColors.success : AppColors.danger;
    final softColor = isOpen ? AppColors.successSoft : AppColors.dangerSoft;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            isOpen ? Icons.storefront_outlined : Icons.access_time_rounded,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen ? 'Open now' : 'Closed right now',
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
                Text(
                  isOpen ? settings.hours : 'Please come back later',
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isOpen)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Delivery ${money(settings.deliveryFee)}',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}