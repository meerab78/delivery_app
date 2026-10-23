// Turns any error into a short, readable message.
import 'package:supabase_flutter/supabase_flutter.dart';

String errorText(Object error) {
  if (error is AuthException) return error.message;
  if (error is PostgrestException) return error.message;
  return 'Something went wrong: $error';
}