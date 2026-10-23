// The user types the 6 digit code here.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/snackbar_helper.dart';
import '../controller.dart';

class OtpView extends ConsumerStatefulWidget {
  const OtpView({super.key, required this.phone});

  final String phone; // already in the format +923001234567

  @override
  ConsumerState<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends ConsumerState<OtpView> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _onVerify() async {
    final code = _codeController.text.trim();

    if (code.length != 6) {
      showSnack(context, 'Please enter the 6 digit code');
      return;
    }

    final error = await ref
        .read(authControllerProvider.notifier)
        .verifyOtp(phone: widget.phone, code: code);

    // On success we do nothing here: BaseView notices the login,
    // closes this screen and opens the right side of the app.
    if (error != null && mounted) {
      showSnack(context, error);
    }
  }

  Future<void> _onResend() async {
    final error =
    await ref.read(authControllerProvider.notifier).sendOtp(widget.phone);

    if (!mounted) return;
    showSnack(context, error ?? 'Code sent again');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('We sent a 6 digit code to\n${widget.phone}',
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontSize: 28, letterSpacing: 8),
              decoration: const InputDecoration(
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading ? null : _onVerify,
                child: isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Verify'),
              ),
            ),
            TextButton(
              onPressed: isLoading ? null : _onResend,
              child: const Text('Resend code'),
            ),
          ],
        ),
      ),
    );
  }
}