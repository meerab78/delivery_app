// Admin dashboard data: store switch and today's numbers.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/error_helper.dart';
import '../../order/model/order_model.dart';
import 'repository.dart';

// LIVE: is the store open right now?
final storeOpenProvider = StreamProvider.autoDispose<bool>((ref) {
  return ref.watch(adminDashboardRepositoryProvider).watchStoreOpen();
});

// The numbers shown on the dashboard
class DashboardStats {
  final int todayOrders;
  final double todayRevenue; // only delivered orders
  final int pendingCount; // orders waiting to be accepted

  const DashboardStats({
    required this.todayOrders,
    required this.todayRevenue,
    required this.pendingCount,
  });
}

// Counts everything with a simple loop
DashboardStats calculateStats(List<OrderModel> orders) {
  final now = DateTime.now();
  var todayOrders = 0;
  double todayRevenue = 0;
  var pendingCount = 0;

  for (final order in orders) {
    final date = order.createdAt;
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    if (isToday) {
      todayOrders = todayOrders + 1;
      if (order.status == OrderStatus.delivered) {
        todayRevenue = todayRevenue + order.total;
      }
    }

    if (order.status == OrderStatus.placed) {
      pendingCount = pendingCount + 1;
    }
  }

  return DashboardStats(
    todayOrders: todayOrders,
    todayRevenue: todayRevenue,
    pendingCount: pendingCount,
  );
}

// Open / Close the store. Returns null on success, or the error text.
class StoreOpenController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> setOpen(bool isOpen) async {
    state = const AsyncLoading<void>();
    try {
      await ref.read(adminDashboardRepositoryProvider).setStoreOpen(isOpen);
      state = const AsyncData<void>(null);
      return null;
    } catch (error) {
      state = const AsyncData<void>(null);
      return errorText(error);
    }
  }
}

final storeOpenControllerProvider =
AsyncNotifierProvider<StoreOpenController, void>(() {
  return StoreOpenController();
});