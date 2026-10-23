// Admin categories list: add, rename, show / hide.
import 'package:delivery_app/features/admin/categories/widgets/category_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/shared/add_fab.dart';
import '../../../core/shared/error_view.dart';
import '../../../core/shared/loading_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_helper.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../products/controller.dart';
import '../products/model/admin_category_model.dart';
class AdminCategoriesView extends ConsumerWidget {
  const AdminCategoriesView({super.key});

  void _openDialog(
      BuildContext context, {
        AdminCategoryModel? category,
        required int defaultSortOrder,
      }) {
    showDialog(
      context: context,
      builder: (_) => CategoryFormDialog(
        category: category,
        defaultSortOrder: defaultSortOrder,
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);

    if (categoriesAsync.hasError && !categoriesAsync.hasValue) {
      return ErrorView(
        message: errorText(categoriesAsync.error!),
        onRetry: () => ref.invalidate(adminCategoriesProvider),
      );
    }
    if (!categoriesAsync.hasValue) {
      return const LoadingView();
    }

    final categories = categoriesAsync.value ?? <AdminCategoryModel>[];

    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'No categories yet. Tap "Add category".',
          style: TextStyle(color: AppColors.textLight),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.black12),
            ),
            child: InkWell(
              onTap: () => _openDialog(
                context,
                category: category,
                defaultSortOrder: category.sortOrder,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Opacity(
                        opacity: category.isActive ? 1 : 0.5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              category.isActive
                                  ? 'Order: ${category.sortOrder}'
                                  : 'Order: ${category.sortOrder}  •  Hidden',
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Switch(
                      value: category.isActive,
                      onChanged: (value) async {
                        final error = await ref
                            .read(adminCatalogControllerProvider.notifier)
                            .setCategoryActive(category.id, value);
                        if (!context.mounted) return;
                        if (error != null) {
                          showSnack(context, error);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(adminCategoriesProvider).value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: AddFab(
        label: 'Add category',
        onPressed: () => _openDialog(context, defaultSortOrder: count + 1),
      ),
      body: _buildBody(context, ref),
    );
  }
}