// The profile of the logged-in user (name, phone, role).
// It reloads by itself when a different user logs in.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sessions/session_provider.dart';
import '../../../core/utils/error_helper.dart';
import 'model/model.dart';
import 'repository.dart';

class ProfileController extends AsyncNotifier<ProfileModel?> {
  @override
  Future<ProfileModel?> build() async {
    final userId = ref.watch(userIdProvider);

    // Nobody is logged in
    if (userId == null) return null;

    return ref.read(profileRepositoryProvider).getMyProfile(userId);
  }

  // Returns null if the name was saved, or an error message.
  Future<String?> saveName(String name) async {
    final current = state.value;
    if (current == null) return 'Profile is not loaded yet';

    try {
      await ref.read(profileRepositoryProvider).updateName(current.id, name);
      // Update the screen right away, without loading everything again.
      state = AsyncData(current.copyWith(name: name));
      return null;
    } catch (e) {
      return errorText(e);
    }
  }
}

final profileControllerProvider =
AsyncNotifierProvider<ProfileController, ProfileModel?>(
  ProfileController.new,
);