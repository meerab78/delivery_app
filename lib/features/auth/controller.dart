// Login logic. The screens call these methods.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/error_helper.dart';
import '../notifications/repository.dart';
import 'repository.dart';

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Nothing to load at the start.
  }

  // ----- Phone OTP login -----
  // These return null if it worked, or an error message if it failed.

  Future<String?> sendOtp(String phone) {
    return _run(() => ref.read(authRepositoryProvider).sendOtp(phone));
  }

  Future<String?> verifyOtp({required String phone, required String code}) {
    return _run(
          () => ref
          .read(authRepositoryProvider)
          .verifyOtp(phone: phone, code: code),
    );
  }

  // ----- Email login (only for testing) -----
  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref
          .read(authRepositoryProvider)
          .signInWithEmail(email: email, password: password);
    });
  }

  Future<void> signOut() async {
    // Remove this phone's token first (we must still be logged in to do it).
    await ref.read(notificationRepositoryProvider).unregister();
    await ref.read(authRepositoryProvider).signOut();
  }

  // Runs an action while showing "loading", and turns errors into text.
  Future<String?> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
      return null;
    } catch (e) {
      state = const AsyncData(null);
      return errorText(e);
    }
  }
}

final authControllerProvider =
AsyncNotifierProvider<AuthController, void>(AuthController.new);