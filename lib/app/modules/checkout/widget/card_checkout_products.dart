import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../data/models/cart_model.dart';

class CardCheckoutProducts extends StatelessWidget {
  final CartItemModel item;

  const CardCheckoutProducts({
    super.key,
    required this.item,
    String? url,
    int? index,
    dynamic controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: AppSpacing.roundedMd,
            ),
            padding: const EdgeInsets.all(4),
            child: AppImage(
              imageUrl: item.product.imageThumbnail,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.quantity}x ${CurrencyFormatter.format(item.product.price)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(item.product.price * item.quantity),
            style: AppTextStyles.price.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
