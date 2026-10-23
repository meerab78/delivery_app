// The root widget: theme + first screen.
import 'package:flutter/material.dart';

import 'core/navigations/app_keys.dart';
import 'core/theme/app_theme.dart';
import 'features/base/view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      title: 'Delivery App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // BaseView decides: login / customer side / admin side
      home: const BaseView(),
    );
  }
}