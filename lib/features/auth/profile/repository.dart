// Talks to the profiles table.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/db/supabase_client.dart';
import 'model/model.dart';


class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<ProfileModel> getMyProfile(String userId) async {
    final data =
    await _client.from('profiles').select().eq('id', userId).single();
    return ProfileModel.fromJson(data);
  }

  // The role can NOT be changed from here (the database blocks it).
  Future<void> updateName(String userId, String name) async {
    await _client.from('profiles').update({'name': name}).eq('id', userId);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseProvider));
});