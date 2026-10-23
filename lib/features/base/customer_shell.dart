// The customer side of the app: 3 tabs with a curved bottom bar.
//   Home  |  Orders  |  Profile
// Screens like Cart, Checkout and Track order open ON TOP of this bar.
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../auth/profile/view.dart';
import '../home/view.dart';
import '../order/history/view.dart';
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  // We need this key to move to a tab from code (for the Android back button).
  final GlobalKey<CurvedNavigationBarState> _navKey = GlobalKey();

  int _index = 0; // 0 = Home, 1 = Orders, 2 = Profile

  // The 3 screens, in the same order as the icons below.
  static const List<Widget> _pages = [
    HomeView(),
    OrderHistoryView(),
    ProfileView(),
  ];

  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.receipt_long_rounded,
    Icons.person_rounded,
  ];

  // The selected icon sits inside the white circle, so it is orange.
  // The other icons are white, on the orange bar.
  Widget _buildIcon(int i) {
    return Icon(
      _icons[i],
      size: 28,
      color: _index == i ? AppColors.primary : Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Android back button: from Orders or Profile go back to Home first.
    // From Home it closes the app as usual.
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _navKey.currentState?.setPage(0);
        }
      },
      child: Scaffold(
        // IndexedStack keeps all 3 tabs alive, so scroll position
        // and live order updates are not lost when you switch tabs.
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