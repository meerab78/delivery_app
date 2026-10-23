// Checkout: pick an address, add a note, and place the order.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/shared/error_view.dart';
import '../../../core/shared/loading_view.dart';
import '../../../core/shared/summary_row.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_helper.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../auth/address/add_address/view.dart';
import '../../auth/address/controller.dart';
import '../../auth/address/model/address_model.dart';
import '../../home/controller.dart';
import '../../order/controller.dart';
import '../../order/order_place/view.dart';
import '../controller.dart';

class CheckoutView extends ConsumerStatefulWidget {
  const CheckoutView({super.key});

  @override
  ConsumerState<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends ConsumerState<CheckoutView> {
  final _notesController = TextEditingController();

  // The address the customer tapped (null = use the default one)
  String? _selectedAddressId;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Which address is selected right now?
  // 1) the one the customer tapped, 2) the default one, 3) the first one.
  String? _pickSelectedId(List<AddressModel> addresses) {
    if (addresses.isEmpty) return null;

    final tapped = addresses.where((a) => a.id == _selectedAddressId);
    if (tapped.isNotEmpty) return tapped.first.id;

    final defaults = addresses.where((a) => a.isDefault);
    if (defaults.isNotEmpty) return defaults.first.id;

    return addresses.first.id;
  }

  Future<void> _onPlaceOrder(String addressId) async {
    final items = ref.read(cartControllerProvider);

    final orderId = await ref
        .read(placeOrderControllerProvider.notifier)
        .place(
      addressId: addressId,
      items: items,
      notes: _notesController.text.trim(),
    );

    // null means it failed (the error is shown by ref.listen in build)
    if (orderId == null || !mounted) return;

    ref.read(cartControllerProvider.notifier).clear();

    // Open the success screen and remove checkout + cart from the back stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => OrderPlacedView(orderId: orderId)),
          (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show an error message if placing the order fails
    // (for example: "Sorry, the store is closed right now")
    ref.listen(placeOrderControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        showSnack(context, errorText(next.error!));
      }
    });

    final items = ref.watch(cartControllerProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final settings = ref.watch(storeSettingsProvider).value;
    final addressesAsync = ref.watch(addressesProvider);
    final isPlacing = ref.watch(placeOrderControllerProvider).isLoading;

    final addresses = addressesAsync.value ?? <AddressModel>[];
    final selectedId = _pickSelectedId(addresses);

    final deliveryFee = settings?.deliveryFee ?? 0;
    final minOrder = settings?.minOrder ?? 0;
    final storeOpen = settings?.isOpen ?? true;
    final belowMinimum = subtotal < minOrder;
    final total = subtotal + deliveryFee;

    final canOrder = selectedId != null &&
        items.isNotEmpty &&
        storeOpen &&
        !belowMinimum &&
        !isPlacing;

    // A short reason why the button is disabled
    String? warning;
    if (!storeOpen) {
      warning = 'Store is closed right now';
    } else if (belowMinimum) {
      warning =
      'Minimum order is ${AppConstants.currency} ${minOrder.toStringAsFixed(0)}';
    } else if (selectedId == null && addressesAsync.hasValue) {
      warning = 'Please add a delivery address';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('Delivery address'),
          const SizedBox(height: 10),
          addressesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: LoadingView(),
            ),
            error: (error, _) => ErrorView(
              message: errorText(error),
              onRetry: () => ref.invalidate(addressesProvider),
            ),
            data: (list) => Column(
              children: [
                if (list.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No saved address yet',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  ),
                for (final address in list)
                  _AddressCard(
                    address: address,
                    selected: address.id == selectedId,
                    onTap: () =>
                        setState(() => _selectedAddressId = address.id),
                    onDelete: () => ref
                        .read(addressControllerProvider.notifier)
                        .delete(address.id),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: const Text('Add new address'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddAddressView(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionTitle('Payment'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.successSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.payments_outlined,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cash on Delivery',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pay when your order arrives',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Note'),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Note for the store (optional)',
            ),
          ),
        ],
      ),
      // Summary + button at the bottom
      // NOTE: these numbers are only a preview.
      // The REAL total is calculated by the database in place_order().
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SummaryRow(label: 'Subtotal', amount: subtotal),
              SummaryRow(label: 'Delivery fee', amount: deliveryFee),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Divider(),
              ),
              SummaryRow(label: 'Total', amount: total, bold: true),
              if (warning != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    warning,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: canOrder ? () => _onPlaceOrder(selectedId) : null,
                child: isPlacing
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primary,
                        ),
                      )
                    : Text(
                        'Place order  •  ${AppConstants.currency} ${total.toStringAsFixed(0)}',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// A bold title above each section (Delivery address, Payment...)
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),
    );
  }
}

// One saved address. Orange border when it is selected.
class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  final AddressModel address;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  // Icon changes with the label: Home, Office, Other
  IconData _iconFor(String label) {
    if (label == 'Home') return Icons.home_outlined;
    if (label == 'Office') return Icons.work_outline;
    return Icons.location_on_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primarySoft : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
            child: Row(
              children: [
                Icon(
                  _iconFor(address.label),
                  color: selected ? AppColors.primary : AppColors.textGrey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        address.fullAddress,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle, color: AppColors.primary),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.textGrey,
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
