// Profile screen: name, phone, edit name, addresses, logout.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../address/view.dart';
import '../controller.dart';
import 'controller.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  Future<void> _editName(
      BuildContext context,
      WidgetRef ref,
      String currentName,
      ) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _EditNameDialog(initialName: currentName),
    );

    if (newName == null || newName.length < 2) return;

    final error =
    await ref.read(profileControllerProvider.notifier).saveName(newName);

    if (error != null && context.mounted) {
      showSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider).value;
    final name = profile?.name ?? '';
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('My profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              child: Text(initial, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(name.isEmpty ? 'No name' : name,
                style: Theme.of(context).textTheme.titleLarge),
          ),
          Center(child: Text(profile?.phone ?? '')),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit name'),
            onTap: () => _editName(context, ref, name),
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('My addresses'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressesView()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}

// A small dialog that owns its own text controller.
class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initialName});

  final String initialName;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit name'),
      content: TextField(
        controller: _controller,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Your name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}