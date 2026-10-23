// Picks the right screen:
//   not logged in            -> Signin
//   logged in, admin         -> Admin dashboard
//   logged in, no name yet   -> Profile setup
//   logged in, customer      -> Home
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/sessions/session_provider.dart';
import '../../core/shared/error_view.dart';
import '../../core/utils/error_helper.dart';
import '../admin/admin_shell.dart';
import '../admin/dashboard/view.dart';
import '../auth/controller.dart';
import '../auth/profile/controller.dart';
import '../auth/profile/setup/view.dart';
import '../auth/signin/view.dart';
import '../auth/splash/view.dart';
import '../home/view.dart';
import '../notifications/handler.dart';
import '../notifications/repository.dart';
import 'customer_shell.dart';

class BaseView extends ConsumerWidget {
  const BaseView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // When a user logs in or out, close every screen that was opened on top
    // (like the OTP screen or the profile screen), so we land on the right one.
    ref.listen(sessionProvider, (previous, next) {
      final before = previous?.value?.user.id;
      final after = next.value?.user.id;
      if (before != after) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    final session = ref.watch(sessionProvider);
    // When a user logs in, save this phone's notification token.
    ref.listen(userIdProvider, (previous, next) {
      if (next != null) {
        ref.read(notificationRepositoryProvider).register();
      }
    });

    return session.when(
      loading: () => const SplashView(),
      error: (error, _) => Scaffold(
        body: ErrorView(
          message: errorText(error),
          onRetry: () => ref.invalidate(sessionProvider),
        ),
      ),
      data: (currentSession) {
        // Nobody is logged in
        if (currentSession == null) {
          return const SigninView();
        }

        // Someone is logged in: load their profile (name + role)
        final profile = ref.watch(profileControllerProvider);

        return profile.when(
          loading: () => const SplashView(),
          error: (error, _) => Scaffold(
            body: ErrorView(
              message: errorText(error),
              onRetry: () => ref.invalidate(profileControllerProvider),
              secondaryLabel: 'Log out',
              onSecondary: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
            ),
          ),
          data: (me) {
            if (me == null) return const SplashView();
            if (!me.isAdmin && !me.hasName) return const ProfileSetupView();

            // If the user opened the app by tapping a notification,
            // open that order as soon as the home screen is ready.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              NotificationHandler.openPendingIfAny();
            });
            if (me.isAdmin) return const AdminShell();
            return const CustomerShell();
          },
        );
      },
    );
  }
}