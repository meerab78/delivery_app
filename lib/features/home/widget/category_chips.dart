// A horizontal row of category buttons: All, Drinks, Snacks...
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../model/category_model.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CategoryModel> categories;
  final String? selectedId; // null means "All"
  final ValueChanged<String?> onSelected;

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textDark,
          fontWeight: FontWeight.w600,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip('All', selectedId == null, () => onSelected(null)),
          for (final category in categories)
            _chip(
              category.name,
              selectedId == category.id,
                  () => onSelected(category.id),
            ),
        ],
      ),
    );
  }
}