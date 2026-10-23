// Login screen: orange header + a mobile number box.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/phone_helper.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../controller.dart';
import '../otp/view.dart';
import 'email_view.dart';

class SigninView extends ConsumerStatefulWidget {
  const SigninView({super.key});

  @override
  ConsumerState<SigninView> createState() => _SigninViewState();
}

class _SigninViewState extends ConsumerState<SigninView> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSendOtp() async {
    final phone = normalizePkPhone(_phoneController.text);

    if (phone == null) {
      showSnack(context, 'Please enter a valid mobile number, like 0300 1234567');
      return;
    }

    final error =
    await ref.read(authControllerProvider.notifier).sendOtp(phone);

    if (!mounted) return;

    if (error != null) {
      showSnack(context, error);
      return;
    }

    // The code was sent: open the screen where the user types it.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OtpView(phone: phone)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ----- Orange header -----
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.of(context).padding.top + 40,
              24,
              40,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, Color(0xFFFF8A3D)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delivery_dining,
                    size: 44,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  AppConstants.storeName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Fast delivery to your door',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // ----- Login form -----
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Login or sign up',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enter your mobile number. We will send you a code.',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile number',
                      hintText: '0300 1234567',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLoading ? null : _onSendOtp,
                      child: isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text('Send OTP'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EmailSigninView(),
                          ),
                        );
                      },
                      child: const Text('Login with email (testing)'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}