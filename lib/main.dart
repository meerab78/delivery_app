// The app starts here.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/constants/supabase_config.dart';
import 'features/notifications/handler.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Connect the app to Firebase (for push notifications)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Connect the app to our Supabase project
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Start listening for notification banners and taps
  await NotificationHandler.init();

  // ProviderScope is what makes Riverpod work in the whole app
  runApp(const ProviderScope(child: MyApp()));
}