// A small colored pill: "Preparing", "Delivered"...
import 'package:flutter/material.dart';

import '../order_status_helper.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusSoftColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusLabel(status),
        style: TextStyle(
          color: statusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}