// "My addresses": the list of saved addresses.
// Each address has a menu: Make default / Delete.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/shared/error_view.dart';
import '../../../core/shared/loading_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_helper.dart';
import '../../../core/utils/snackbar_helper.dart';
import 'add_address/view.dart';
import 'controller.dart';
import 'model/address_model.dart';

class AddressesView extends ConsumerWidget {
  const AddressesView({super.key});

  // Icon changes with the label: Home, Office, Other
  IconData _iconFor(String label) {
    if (label == 'Home') return Icons.home_outlined;
    if (label == 'Office') return Icons.work_outline;
    return Icons.location_on_outlined;
  }

  Future<void> _onMenu(
      BuildContext context,
      WidgetRef ref,
      String value,
      AddressModel address,
      ) async {
    final controller = ref.read(addressControllerProvider.notifier);

    if (value == 'default') {
      final error = await controller.setDefault(address.id);
      if (error != null && context.mounted) {
        showSnack(context, error);
      }
    } else if (value == 'delete') {
      await controller.delete(address.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My addresses')),
      body: addresses.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: errorText(error),
          onRetry: () => ref.invalidate(addressesProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No saved address yet'));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
            children: [
              for (final address in list)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: address.isDefault
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      _iconFor(address.label),
                      color: address.isDefault
                          ? AppColors.primary
                          : AppColors.textLight,
                    ),
                    title: Row(
                      children: [
                        Text(
                          address.label,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(address.fullAddress),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) =>
                          _onMenu(context, ref, value, address),
                      itemBuilder: (_) => [
                        if (!address.isDefault)
                          const PopupMenuItem(
                            value: 'default',
                            child: Text('Make default'),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add address'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAddressView()),
          );
        },
      ),
    );
  }
}