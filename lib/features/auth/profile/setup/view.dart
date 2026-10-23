// Shown ONCE after the first login, to ask the customer's name.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../controller.dart';
import '../controller.dart';

class ProfileSetupView extends ConsumerStatefulWidget {
  const ProfileSetupView({super.key});

  @override
  ConsumerState<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends ConsumerState<ProfileSetupView> {
  final _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();

    if (name.length < 2) {
      showSnack(context, 'Please enter your name');
      return;
    }

    setState(() => _isSaving = true);

    final error =
    await ref.read(profileControllerProvider.notifier).saveName(name);

    // On success BaseView swaps this screen for Home, so this screen is gone.
    if (!mounted) return;

    setState(() => _isSaving = false);
    if (error != null) showSnack(context, error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.waving_hand_outlined, size: 64),
                const SizedBox(height: 16),
                Text("What's your name?",
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                const Text('We use it so the rider knows who to call.'),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Continue'),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).signOut(),
                  child: const Text('Use a different number'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}