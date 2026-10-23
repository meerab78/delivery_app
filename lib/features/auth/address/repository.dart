// Talks to the addresses table.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/db/supabase_client.dart';
import 'model/address_model.dart';

class AddressRepository {
  AddressRepository(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  // Default address first, then newest first.
  Future<List<AddressModel>> getAddresses() async {
    final data = await _client
        .from('addresses')
        .select()
        .eq('user_id', _userId)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);
    return data.map((row) => AddressModel.fromJson(row)).toList();
  }

  // The very first address becomes the default one.
  Future<void> addAddress({
    required String label,
    required String fullAddress,
  }) async {
    final existing =
    await _client.from('addresses').select('id').eq('user_id', _userId);

    await _client.from('addresses').insert({
      'user_id': _userId,
      'label': label,
      'full_address': fullAddress,
      'is_default': existing.isEmpty,
    });
  }

  // Old orders are safe: they keep their own copy (snapshot) of the address.
  Future<void> deleteAddress(String addressId) async {
    await _client.from('addresses').delete().eq('id', addressId);
  }
  // Makes this address the default one.
  Future<void> setDefault(String addressId) async {
    await _client.rpc('set_default_address', params: {'p_address_id': addressId});
  }
}

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(ref.watch(supabaseProvider));
});