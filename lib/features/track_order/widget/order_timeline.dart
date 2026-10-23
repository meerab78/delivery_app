// The vertical progress line:
//   (o) Order placed
//    |
//   (o) Accepted by store ... and so on
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.status});

  final String status;

  // (status in the database, text to show)
  static const List<(String, String)> _steps = [
    (OrderStatus.placed, 'Order placed'),
    (OrderStatus.accepted, 'Accepted by store'),
    (OrderStatus.preparing, 'Preparing your order'),
    (OrderStatus.outForDelivery, 'Out for delivery'),
    (OrderStatus.delivered, 'Delivered'),
  ];

  @override
  Widget build(BuildContext context) {
    // Which step are we at right now?
    final current = _steps.indexWhere((step) => step.$1 == status);
    final allDone = status == OrderStatus.delivered;

    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++)
          _TimelineRow(
            label: _steps[i].$2,
            isDone: i < current || allDone,
            isCurrent: i == current && !allDone,
            isLast: i == _steps.length - 1,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.label,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
  });

  final String label;
  final bool isDone; // finished steps: orange circle with a check
  final bool isCurrent; // the step we are at: orange ring with a dot
  final bool isLast; // the last step has no line below it

  @override
  Widget build(BuildContext context) {
    final active = isDone || isCurrent;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? AppColors.primary : Colors.white,
                    border: Border.all(
                      color: active ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : isCurrent
                      ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isDone ? AppColors.primary : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                  color: active ? AppColors.textDark : AppColors.textGrey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}