// Handles notifications while the app is running:
//   1) App is OPEN        -> show a banner with a "VIEW" button
//   2) App in BACKGROUND  -> user taps the notification -> open the order
//   3) App was CLOSED     -> user taps the notification -> open the order
//
// Our Edge Function sends two extra values with every notification:
//   type:     new_order | order_cancelled | order_status
//   order_id: the id of the order
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/navigations/app_keys.dart';
import '../admin/order/details/view.dart';
import '../track_order/view.dart';

class NotificationHandler {
  // A tap that happened before the app was ready (for example the app was closed).
  // BaseView opens it as soon as the home screen is on the screen.
  static Map<String, dynamic>? _pendingTap;

  static bool _started = false;

  // Call this ONCE, in main(), after Firebase and Supabase are ready.
  static Future<void> init() async {
    if (_started) return;
    _started = true;

    // 1) A notification arrives while the app is OPEN.
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // 2) The user taps a notification while the app is in the BACKGROUND.
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

    // 3) The user taps a notification while the app was CLOSED.
    final firstMessage = await FirebaseMessaging.instance.getInitialMessage();
    final loggedIn = Supabase.instance.client.auth.currentSession != null;
    if (firstMessage != null && loggedIn) {
      _pendingTap = firstMessage.data;
    }
  }

  // Shows a banner at the bottom while the app is open.
  static void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    final title = notification.title ?? '';
    final body = notification.body ?? '';

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(body),
          ],
        ),
        action: SnackBarAction(
          label: 'VIEW',
          onPressed: () {
            handleTap(message.data);
          },
        ),
      ),
    );
  }

  static void _onMessageOpened(RemoteMessage message) {
    handleTap(message.data);
  }

  // Opens the right screen now, or remembers it if the app is not ready yet.
  static void handleTap(Map<String, dynamic> data) {
    final loggedIn = Supabase.instance.client.auth.currentSession != null;
    if (!loggedIn) return;

    if (navigatorKey.currentState == null) {
      _pendingTap = data;
      return;
    }

    _open(data);
  }

  // BaseView calls this when the home screen is ready.
  static void openPendingIfAny() {
    final data = _pendingTap;
    if (data == null) return;

    _pendingTap = null;
    _open(data);
  }

  static void _open(Map<String, dynamic> data) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    final String? orderId = data['order_id'] as String?;
    final String? type = data['type'] as String?;
    if (orderId == null) return;

    if (type == 'order_status') {
      // The customer: show the live tracking screen.
      navigator.push(
        MaterialPageRoute(builder: (_) => TrackOrderView(orderId: orderId)),
      );
    } else if (type == 'new_order' || type == 'order_cancelled') {
      // The admin: show the order detail screen.
      navigator.push(
        MaterialPageRoute(builder: (_) => AdminOrderDetailView(orderId: orderId)),
      );
    }
  }
}