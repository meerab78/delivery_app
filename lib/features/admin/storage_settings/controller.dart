// Providers and actions for the admin store settings screen.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_helper.dart';
import 'model/model.dart';
import 'repository.dart';

// Loads the settings once
final adminStoreSettingsProvider =
FutureProvider.autoDispose<AdminStoreSettings>((ref) {
  return ref.watch(adminStoreSettingsRepositoryProvider).getSettings();
});

// Saves the settings. Returns null on success, or the error text.
class AdminStoreSettingsController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> save({
    required double deliveryFee,
    required double minOrder,
    required String hours,
  }) async {
    state = const AsyncLoading<void>();
    try {
      await ref.read(adminStoreSettingsRepositoryProvider).saveSettings(
        deliveryFee: deliveryFee,
        minOrder: minOrder,
        hours: hours,
      );
      state = const AsyncData<void>(null);
      return null;
    } catch (error) {
      state = const AsyncData<void>(null);
      return errorText(error);
    }
  }
}

final adminStoreSettingsControllerProvider =
AsyncNotifierProvider<AdminStoreSettingsController, void>(() {
  return AdminStoreSettingsController();
});