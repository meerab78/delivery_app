// The ONLY place that talks to Supabase for login.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/db/supabase_client.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  // Step 1: Supabase sends a 6 digit code by SMS.
  // If the number is new, the user is created automatically.
  Future<void> sendOtp(String phone) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  // Step 2: the user types the code. If it is correct, they are logged in.
  Future<void> verifyOtp({required String phone, required String code}) async {
    await _client.auth.verifyOTP(
      phone: phone,
      token: code,
      type: OtpType.sms,
    );
  }

  // Email login, only for testing.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseProvider));
});