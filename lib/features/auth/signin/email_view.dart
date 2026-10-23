// Email login, only for testing.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_helper.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../controller.dart';

class EmailSigninView extends ConsumerStatefulWidget {
  const EmailSigninView({super.key});

  @override
  ConsumerState<EmailSigninView> createState() => _EmailSigninViewState();
}

class _EmailSigninViewState extends ConsumerState<EmailSigninView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showSnack(context, 'Please enter email and password');
      return;
    }

    // On success the app changes screen by itself (see BaseView).
    ref
        .read(authControllerProvider.notifier)
        .signIn(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    // listen = do something when the state changes (here: show an error)
    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        showSnack(context, errorText(next.error!));
      }
    });

    // watch = rebuild this screen when the state changes
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Email login')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Round orange logo
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delivery_dining,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Login to order your favourite food',
                  style: TextStyle(color: AppColors.textDark, fontSize: 15),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: isLoading ? null : _onLoginPressed,
                  child: isLoading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  )
                      : const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}