// Saves and removes this phone's push notification token.
// This is the ONLY place that talks to FCM and to the device_tokens table.
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/db/supabase_client.dart';

class NotificationRepository {
  NotificationRepository(this._client);

  final SupabaseClient _client;

  // Listens for token changes (Firebase can give a new token sometimes).
  StreamSubscription<String>? _refreshSubscription;

  // Call this after login.
  // It asks for permission, gets the token and saves it in Supabase.
  Future<void> register() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Android 13+ shows an "Allow notifications?" dialog here.
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('Notifications are not allowed on this phone');
        return;
      }

      final token = await messaging.getToken();
      if (token != null) {
        await _saveToken(token);
      }

      // Save the new token if Firebase changes it later.
      await _refreshSubscription?.cancel();
      _refreshSubscription = messaging.onTokenRefresh.listen(_saveToken);
    } catch (e) {
      // Notifications are a bonus, so a failure must never break the app.
      debugPrint('Could not register for notifications: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    try {
      await _client.rpc('register_device_token', params: {'p_token': token});
      debugPrint('FCM token saved: ${token.substring(0, 12)}...');
    } catch (e) {
      debugPrint('Could not save the FCM token: $e');
    }
  }

  // Call this BEFORE logout (we must still be logged in to delete the row).
  Future<void> unregister() async {
    try {
      await _refreshSubscription?.cancel();
      _refreshSubscription = null;

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _client.from('device_tokens').delete().eq('fcm_token', token);
      }
    } catch (e) {
      debugPrint('Could not remove the FCM token: $e');
    }
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(supabaseProvider));
});