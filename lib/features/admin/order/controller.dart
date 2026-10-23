// Providers and actions for the admin orders screens.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_helper.dart';
import '../../order/model/order_model.dart';
import '../../order/repository.dart';
import 'repository.dart';

// LIVE list of all orders
final adminOrdersProvider = StreamProvider.autoDispose<List<OrderModel>>((ref) {
  return ref.watch(adminOrdersRepositoryProvider).watchAllOrders();
});

// LIVE updates of ONE order (used by the detail screen)
final adminOrderProvider =
StreamProvider.autoDispose.family<OrderModel, String>((ref, orderId) {
  return ref.watch(orderRepositoryProvider).watchOrder(orderId);
});

// Items of one order (loaded once)
final adminOrderItemsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, orderId) {
  return ref.watch(adminOrdersRepositoryProvider).getOrderItems(orderId);
});

// Changes the status of an order (Accept, Reject, Preparing ...).
// Returns null on success, or the error text.
class AdminOrderActionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> changeStatus({
    required String orderId,
    required String newStatus,
  }) async {
    state = const AsyncLoading<void>();
    try {
      await ref.read(orderRepositoryProvider).updateStatus(
        orderId: orderId,
        newStatus: newStatus,
      );
      state = const AsyncData<void>(null);
      return null;
    } catch (error) {
      state = const AsyncData<void>(null);
      return errorText(error);
    }
  }
}

final adminOrderActionProvider =
AsyncNotifierProvider<AdminOrderActionController, void>(() {
  return AdminOrderActionController();
});