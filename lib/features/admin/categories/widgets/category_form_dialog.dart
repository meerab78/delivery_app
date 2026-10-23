// A small popup to add or rename a category.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../products/controller.dart';
import '../../products/model/admin_category_model.dart';

class CategoryFormDialog extends ConsumerStatefulWidget {
  // category == null -> add a new category
  const CategoryFormDialog({
    super.key,
    this.category,
    required this.defaultSortOrder,
  });

  final AdminCategoryModel? category;
  final int defaultSortOrder;

  @override
  ConsumerState<CategoryFormDialog> createState() =>
      _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _sortController;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final category = widget.category;

    int sortOrder = widget.defaultSortOrder;
    if (category != null) {
      sortOrder = category.sortOrder;
    }

    _nameController = TextEditingController(text: category?.name ?? '');
    _sortController = TextEditingController(text: '$sortOrder');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sortController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _error = 'Please enter a category name';
      });
      return;
    }

    final sortOrder = int.tryParse(_sortController.text.trim()) ?? 0;

    setState(() {
      _saving = true;
      _error = null;
    });

    final error = await ref
        .read(adminCatalogControllerProvider.notifier)
        .saveCategory(
      categoryId: widget.category?.id,
      name: name,
      sortOrder: sortOrder,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _saving = false;
        _error = error;
      });
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit category' : 'Add category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Category name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sortController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Order (small number shows first)',
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.danger, fontSize: 12),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Saving...' : 'Save'),
        ),
      ],
    );
  }
}