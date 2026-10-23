// Order logic: place an order, live order lists, cancel.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/error_helper.dart';
import '../cart/model/cart_item_model.dart';
import 'model/order_item_model.dart';
import 'model/order_model.dart';
import 'repository.dart';

// ----- Place an order -----
class PlaceOrderController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  // Returns the new order id, or null if something failed.
  Future<String?> place({
    required String addressId,
    required List<CartItemModel> items,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      final orderId = await ref
          .read(orderRepositoryProvider)
          .placeOrder(addressId: addressId, items: items, notes: notes);
      state = AsyncData(orderId);
      return orderId;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final placeOrderControllerProvider =
AsyncNotifierProvider<PlaceOrderController, String?>(
  PlaceOrderController.new,
);

// ----- Live data -----

// My orders (updates live).
final myOrdersProvider = StreamProvider.autoDispose<List<OrderModel>>((ref) {
  return ref.watch(orderRepositoryProvider).watchMyOrders();
});

// One order (updates live). "family" = we pass the order id.
final orderProvider =
StreamProvider.autoDispose.family<OrderModel, String>((ref, orderId) {
  return ref.watch(orderRepositoryProvider).watchOrder(orderId);
});

// The items of one order.
final orderItemsProvider = FutureProvider.autoDispose
    .family<List<OrderItemModel>, String>((ref, orderId) {
  return ref.watch(orderRepositoryProvider).getOrderItems(orderId);
});

// ----- Cancel an order -----
class CancelOrderController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  // Returns null if cancelled, or an error message.
  Future<String?> cancel(String orderId) async {
    state = const AsyncLoading();
    try {
      await ref.read(orderRepositoryProvider).updateStatus(
        orderId: orderId,
        newStatus: OrderStatus.cancelled,
      );
      state = const AsyncData(null);
      return null;
    } catch (e) {
      state = const AsyncData(null);
      return errorText(e);
    }
  }
}

final cancelOrderControllerProvider =
AsyncNotifierProvider<CancelOrderController, void>(
  CancelOrderController.new,
);