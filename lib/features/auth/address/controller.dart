// Address data + the actions (add, delete).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_helper.dart';
import 'model/address_model.dart';
import 'repository.dart';

// The list of saved addresses.
final addressesProvider = FutureProvider.autoDispose<List<AddressModel>>((ref) {
  return ref.watch(addressRepositoryProvider).getAddresses();
});

// The actions. Its state tells us: loading / error / done.
class AddressController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  // Returns true if the address was saved.
  Future<bool> add({required String label, required String fullAddress}) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(addressRepositoryProvider)
          .addAddress(label: label, fullAddress: fullAddress);
      state = const AsyncData(null);
      ref.invalidate(addressesProvider); // reload the list
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<void> delete(String addressId) async {
    try {
      await ref.read(addressRepositoryProvider).deleteAddress(addressId);
      ref.invalidate(addressesProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
  // Returns null if it worked, or an error message.
  Future<String?> setDefault(String addressId) async {
    try {
      await ref.read(addressRepositoryProvider).setDefault(addressId);
      ref.invalidate(addressesProvider);
      return null;
    } catch (e) {
      return errorText(e);
    }
  }
}

final addressControllerProvider =
AsyncNotifierProvider<AddressController, void>(AddressController.new);