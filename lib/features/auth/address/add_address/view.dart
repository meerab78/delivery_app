// A simple form to save a new address.
// (A map pin will be added later.)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../controller.dart';

class AddAddressView extends ConsumerStatefulWidget {
  const AddAddressView({super.key});

  @override
  ConsumerState<AddAddressView> createState() => _AddAddressViewState();
}

class _AddAddressViewState extends ConsumerState<AddAddressView> {
  final _addressController = TextEditingController();
  String _label = 'Home';

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _addressController.text.trim();

    if (text.length < 10) {
      showSnack(context, 'Please write the full address');
      return;
    }

    final saved = await ref
        .read(addressControllerProvider.notifier)
        .add(label: _label, fullAddress: text);

    if (saved && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show an error message if saving fails
    ref.listen(addressControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        showSnack(context, errorText(next.error!));
      }
    });

    final isLoading = ref.watch(addressControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('New address')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Label',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              for (final label in ['Home', 'Office', 'Other'])
                ChoiceChip(
                  label: Text(label),
                  selected: _label == label,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.primary,
                  side: BorderSide(
                    color:
                        _label == label ? AppColors.primary : AppColors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _label == label ? Colors.white : AppColors.textDark,
                  ),
                  onSelected: (_) => setState(() => _label = label),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Full address',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _addressController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'House no, street, area, city',
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: isLoading ? null : _save,
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  )
                : const Text('Save address'),
          ),
        ],
      ),
    );
  }
}
