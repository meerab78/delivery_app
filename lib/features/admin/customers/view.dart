// Admin: the list of customers with a call button.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/shared/error_view.dart';
import '../../../core/shared/loading_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_helper.dart';
import '../../../core/utils/money_helper.dart';
import 'controller.dart';

class CustomersView extends ConsumerWidget {
  const CustomersView({super.key});

  Future<void> _call(String phone) async {
    // The phone is saved like 923001234567. A phone call needs a + in front.
    String number = phone;
    if (!number.startsWith('+')) {
      number = '+$number';
    }
    await launchUrl(Uri.parse('tel:$number'));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: customers.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: errorText(error),
          onRetry: () => ref.invalidate(customersProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No customers yet'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(customersProvider);
              try {
                await ref.read(customersProvider.future);
              } catch (_) {
                // The error is shown by the list itself.
              }
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final customer in list)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primarySoft,
                        child: Text(
                          customer.name.isEmpty
                              ? '?'
                              : customer.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      title: Text(
                        customer.name.isEmpty ? 'No name' : customer.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${customer.phone}\n${customer.ordersCount} orders  •  ${money(customer.totalSpent)} spent',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.call, color: AppColors.success),
                        onPressed: customer.phone.isEmpty
                            ? null
                            : () => _call(customer.phone),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}