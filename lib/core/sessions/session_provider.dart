// Tracks WHO is logged in.
// (The role and name now live in the profile feature.)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../db/supabase_client.dart';

// The current login session (changes on login / logout).
final sessionProvider = StreamProvider<Session?>((ref) async* {
  final client = ref.watch(supabaseProvider);

  // First: what is the state right now?
  yield client.auth.currentSession;

  // Then: send a new value every time the user logs in or out.
  await for (final data in client.auth.onAuthStateChange) {
    yield data.session;
  }
});

// Only the user id (null = nobody logged in).
// It changes only on login/logout, not on every token refresh.
final userIdProvider = Provider<String?>((ref) {
  return ref.watch(sessionProvider).value?.user.id;
});