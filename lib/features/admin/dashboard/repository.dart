// Talks to Supabase for the admin dashboard (store open / closed).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/db/supabase_client.dart';

class AdminDashboardRepository {
  AdminDashboardRepository(this._client);

  final SupabaseClient _client;

  // LIVE value of store_settings.is_open (the table has ONE row, id = 1)
  Stream<bool> watchStoreOpen() {
    return _client
        .from('store_settings')
        .stream(primaryKey: ['id'])
        .eq('id', 1)
        .where((rows) => rows.isNotEmpty)
        .map((rows) => rows.first['is_open'] as bool);
  }

  // Only the admin is allowed to do this (RLS)
  Future<void> setStoreOpen(bool isOpen) async {
    await _client
        .from('store_settings')
        .update({'is_open': isOpen}).eq('id', 1);
  }
}

final adminDashboardRepositoryProvider =
Provider<AdminDashboardRepository>((ref) {
  return AdminDashboardRepository(ref.watch(supabaseProvider));
});