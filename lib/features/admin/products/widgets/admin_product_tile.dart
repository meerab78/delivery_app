// One compact product row in the admin list.
// Image | name, price, category | In stock switch
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/shared/product_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../model/admin_product_model.dart';

class AdminProductTile extends StatelessWidget {
  const AdminProductTile({
    super.key,
    required this.product,
    required this.categoryName,
    required this.onTap,
    required this.onInStockChanged,
  });

  final AdminProductModel product;
  final String categoryName;
  final VoidCallback onTap;
  final ValueChanged<bool> onInStockChanged;

  @override
  Widget build(BuildContext context) {
    // Hidden products look faded
    final opacity = product.isActive ? 1.0 : 0.45;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFEDEDED)),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Small picture
                Opacity(
                  opacity: opacity,
                  child: ProductImage(
                    imageUrl: product.imageUrl,
                    name: product.name,
                    width: 52,
                    height: 52,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),

                // Name, price, category
                Expanded(
                  child: Opacity(
                    opacity: opacity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            if (!product.isActive)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.dangerSoft,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Hidden',
                                  style: TextStyle(
                                    color: AppColors.danger,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              '${AppConstants.currency} ${product.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                categoryName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Small In stock switch
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: product.inStock,
                        onChanged: onInStockChanged,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    Text(
                      product.inStock ? 'In stock' : 'Out',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: product.inStock
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}