// Turns 540.0 into "Rs 540".
import '../constants/app_constants.dart';

String money(double amount) {
  return '${AppConstants.currency} ${amount.toStringAsFixed(0)}';
}