// The admin side of the app: 4 tabs with a curved bottom bar.
//   Dashboard  |  Orders  |  Products  |  Settings
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:delivery_app/features/admin/storage_settings/view.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'dashboard/view.dart';
import 'order/view.dart';
import 'products/view.dart';
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  // We need this key to move to a tab from code (for the Android back button).
  final GlobalKey<CurvedNavigationBarState> _navKey = GlobalKey();

  int _index = 0; // 0 = Dashboard, 1 = Orders, 2 = Products, 3 = Settings

  static const List<Widget> _pages = [
    AdminDashboardView(),
    AdminOrdersView(),
    AdminProductsView(),
    AdminSettingsView(),
  ];

  static const List<IconData> _icons = [
    Icons.dashboard_rounded,
    Icons.receipt_long_rounded,
    Icons.inventory_2_rounded,
    Icons.settings_rounded,
  ];

  // Selected icon is orange (inside the white circle), others are white.
  Widget _buildIcon(int i) {
    return Icon(
      _icons[i],
      size: 28,
      color: _index == i ? AppColors.primary : Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Android back button: go to Dashboard first, then close the app.
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _navKey.currentState?.setPage(0);
        }
      },
      child: Scaffold(
        // IndexedStack keeps all tabs alive (live orders are not lost)
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar: CurvedNavigationBar(
          key: _navKey,
          index: _index,
          height: 62,
          items: [for (var i = 0; i < _icons.length; i++) _buildIcon(i)],
          color: AppColors.primary,
          buttonBackgroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 350),
          onTap: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}