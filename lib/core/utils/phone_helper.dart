// Converts what the user types into the international format Supabase needs.
//   0300 1234567   ->  +923001234567
//   +92 300 1234567 -> +923001234567
// Returns null if it is not a valid Pakistani mobile number.
// (If your customers are in another country, we can change this later.)
String? normalizePkPhone(String input) {
  // Keep only digits and +
  var digits = input.replaceAll(RegExp(r'[^0-9+]'), '');

  if (digits.startsWith('+')) {
    digits = digits.substring(1);
  } else if (digits.startsWith('00')) {
    digits = digits.substring(2);
  } else if (digits.startsWith('0')) {
    digits = '92${digits.substring(1)}';
  } else if (digits.startsWith('3')) {
    digits = '92$digits';
  }

  // A Pakistani mobile number is: 92 + 3XXXXXXXXX (12 digits in total)
  final isValid = RegExp(r'^923\d{9}$').hasMatch(digits);
  if (!isValid) return null;

  return '+$digits';
}