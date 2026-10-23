// Talks to Supabase for the store settings (admin only can update, by RLS).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/db/supabase_client.dart';
import 'model/model.dart';

class AdminStoreSettingsRepository {
  AdminStoreSettingsRepository(this._client);

  final SupabaseClient _client;

  // The table has ONE row (id = 1)
  Future<AdminStoreSettings> getSettings() async {
    final row =
    await _client.from('store_settings').select().eq('id', 1).single();
    return AdminStoreSettings.fromJson(row);
  }

  // is_open is NOT here. It has its own live switch.
  Future<void> saveSettings({
    required double deliveryFee,
    required double minOrder,
    required String hours,
  }) async {
    await _client.from('store_settings').update({
      'delivery_fee': deliveryFee,
      'min_order': minOrder,
      'hours': hours,
    }).eq('id', 1);
  }
}

final adminStoreSettingsRepositoryProvider =
Provider<AdminStoreSettingsRepository>((ref) {
  return AdminStoreSettingsRepository(ref.watch(supabaseProvider));
});