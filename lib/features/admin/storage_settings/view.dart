// Admin store settings: open / close, delivery fee, minimum order, hours.
// It also has the Log out button.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/shared/error_view.dart';
import '../../../core/shared/loading_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_helper.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../auth/controller.dart';
import '../customers/view.dart';
import '../dashboard/controller.dart';
import 'controller.dart';
import 'model/model.dart';

class AdminSettingsView extends ConsumerWidget {
  const AdminSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(adminStoreSettingsProvider);

    Widget body;
    if (settingsAsync.hasValue) {
      body = _SettingsForm(settings: settingsAsync.value!);
    } else if (settingsAsync.hasError) {
      body = ErrorView(
        message: errorText(settingsAsync.error!),
        onRetry: () => ref.invalidate(adminStoreSettingsProvider),
      );
    } else {
      body = const LoadingView();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: body,
    );
  }
}

// Shows "150" instead of "150.0"
String _numberText(double value) {
  if (value % 1 == 0) {
    return value.toStringAsFixed(0);
  }
  return value.toString();
}


// The form. It is a separate widget, so the text fields are created
// ONE time with the loaded values.
class _SettingsForm extends ConsumerStatefulWidget {
  const _SettingsForm({required this.settings});

  final AdminStoreSettings settings;

  @override
  ConsumerState<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<_SettingsForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _feeController;
  late final TextEditingController _minController;
  late final TextEditingController _hoursController;

  @override
  void initState() {
    super.initState();
    _feeController =
        TextEditingController(text: _numberText(widget.settings.deliveryFee));
    _minController =
        TextEditingController(text: _numberText(widget.settings.minOrder));
    _hoursController = TextEditingController(text: widget.settings.hours);
  }

  @override
  void dispose() {
    _feeController.dispose();
    _minController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  // A number must be 0 or more
  String? _validateAmount(String? value) {
    final amount = double.tryParse((value ?? '').trim());
    if (amount == null || amount < 0) {
      return 'Enter a valid amount';
    }
    return null;
  }

  Future<void> _toggleStore(bool value) async {
    final error =
    await ref.read(storeOpenControllerProvider.notifier).setOpen(value);
    if (!mounted) return;
    if (error != null) {
      showSnack(context, error);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final error =
    await ref.read(adminStoreSettingsControllerProvider.notifier).save(
      deliveryFee: double.parse(_feeController.text.trim()),
      minOrder: double.parse(_minController.text.trim()),
      hours: _hoursController.text.trim(),
    );

    if (!mounted) return;
    if (error != null) {
      showSnack(context, error);
    } else {
      showSnack(context, 'Settings saved');
    }
  }

  // Card with the Open / Closed switch (LIVE, saved right away)
  Widget _buildStoreCard() {
    final openAsync = ref.watch(storeOpenProvider);
    final isOpen = openAsync.value ?? false;
    final saving = ref.watch(storeOpenControllerProvider).isLoading;
    final canToggle = openAsync.hasValue && !saving;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOpen ? AppColors.successSoft : AppColors.dangerSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: isOpen ? AppColors.success : AppColors.danger,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen ? 'Store is open' : 'Store is closed',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Saved right away',
                  style: TextStyle(color: AppColors.textLight, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: isOpen,
            onChanged: canToggle ? _toggleStore : null,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(adminStoreSettingsControllerProvider).isLoading;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStoreCard(),
                _sectionTitle('Delivery'),
                TextFormField(
                  controller: _feeController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Delivery fee (${AppConstants.currency})',
                    helperText: 'Use 0 for free delivery',
                  ),
                  validator: _validateAmount,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _minController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Minimum order (${AppConstants.currency})',
                    helperText: 'Use 0 for no minimum',
                  ),
                  validator: _validateAmount,
                ),
                _sectionTitle('Opening hours'),
                TextFormField(
                  controller: _hoursController,
                  decoration: const InputDecoration(
                    labelText: 'Hours',
                    hintText: 'Example: 10:00 AM - 11:00 PM',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: const Text('Customers'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CustomersView()),
                    );
                  },
                ),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).signOut(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Log out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    minimumSize: const Size(0, 48),
                    side: const BorderSide(color: AppColors.danger),
                  ),
                ),
              ],
            ),
          ),
          // Save button stays at the bottom
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: saving ? null : _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 52),
                  ),
                  child: saving
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Save settings'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}