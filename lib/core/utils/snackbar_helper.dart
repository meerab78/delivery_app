// Shows a short message at the bottom of the screen.
import 'package:flutter/material.dart';

void showSnack(BuildContext context, String text) {
  final messenger = ScaffoldMessenger.of(context);
  // Remove the old message first, so the new one shows right away.
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(SnackBar(content: Text(text)));
}
