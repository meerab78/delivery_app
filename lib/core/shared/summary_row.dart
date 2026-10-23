// A small row like:  Subtotal ............ Rs 540
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.label,
    required this.amount,
    this.bold = false,
  });

  final String label;
  final double amount;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      fontSize: bold ? 18 : 14,
      color: bold ? AppColors.textDark : AppColors.textLight,
    );

    // The amount is always dark, so it is easy to read
    final amountStyle = style.copyWith(color: AppColors.textDark);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            '${AppConstants.currency} ${amount.toStringAsFixed(0)}',
            style: amountStyle,
          ),
        ],
      ),
    );
  }
}
