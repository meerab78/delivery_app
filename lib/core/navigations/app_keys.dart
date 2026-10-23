// Two global keys, so we can open screens and show banners
// from anywhere (even outside a widget), for example when a notification arrives.
import 'package:flutter/material.dart';

// Lets us push screens without a BuildContext.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Lets us show a SnackBar without a BuildContext.
final GlobalKey<ScaffoldMessengerState> messengerKey =
GlobalKey<ScaffoldMessengerState>();