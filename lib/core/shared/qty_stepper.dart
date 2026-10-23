// The  [ -  2  + ]  pill used on product cards and in the cart.
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class QtyStepper extends StatelessWidget {
  const QtyStepper({
    super.key,
    required this.qty,
    required this.onIncrease,
    required this.onDecrease,
    this.dense = false, // dense = a smaller version
  });

  final int qty;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final bool dense;

  Widget _button(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(dense ? 5 : 7),
        child: Icon(icon, size: dense ? 16 : 18, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(Icons.remove, onDecrease),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: dense ? 4 : 6),
            child: Text(
              '$qty',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: dense ? 13 : 15,
              ),
            ),
          ),
          _button(Icons.add, onIncrease),
        ],
      ),
    );
  }
}