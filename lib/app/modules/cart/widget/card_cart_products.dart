import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../data/models/cart_model.dart';
import '../controllers/cart_controller.dart';

class CardCartproduct extends StatelessWidget {
  final CartItemModel item;
  final CartController controller;

  const CardCartproduct({
    super.key,
    required this.item,
    required this.controller,
    String? url,
    int? index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.roundedXl,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: AppSpacing.roundedLg,
            ),
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: AppImage(
              imageUrl: item.product.imageThumbnail,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Details & Stepper
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        style: AppTextStyles.titleSmall.copyWith(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => controller.deleteCart(id: item.product.id),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  CurrencyFormatter.format(item.product.price),
                  style: AppTextStyles.price.copyWith(fontSize: 14),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Stepper Counter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTertiary,
                    borderRadius: AppSpacing.roundedPill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        borderRadius: AppSpacing.roundedPill,
                        onTap: () => controller.reduceCart(id: item.product.id),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.remove_rounded, size: 16, color: AppColors.textPrimary),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          item.quantity.toString(),
                          style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      InkWell(
                        borderRadius: AppSpacing.roundedPill,
                        onTap: () => controller.addToCart(id: item.product.id),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.add_rounded, size: 16, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
