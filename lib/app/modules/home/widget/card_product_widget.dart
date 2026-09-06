import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class CardProductWidget extends StatelessWidget {
  final String id;
  final String imageThumbnail;
  final String name;
  final int price;
  final String? category;
  final bool like;
  final HomeController homeController;

  const CardProductWidget({
    super.key,
    required this.id,
    required this.imageThumbnail,
    required this.name,
    required this.price,
    this.category,
    required this.like,
    required this.homeController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.roundedXl,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed('${Routes.HOME}detail-product/$id'),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with floating like button
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          borderRadius: AppSpacing.roundedLg,
                        ),
                        child: Center(
                          child: AppImage(
                            imageUrl: imageThumbnail,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Material(
                          color: AppColors.surface.withValues(alpha: 0.9),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => homeController.toggleLike(id),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                like ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: like ? AppColors.error : AppColors.textSecondary,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Category tag
                if (category != null && category!.isNotEmpty) ...[
                  Text(
                    category!.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                      letterSpacing: 0.8,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                ],

                // Product Name
                Text(
                  name,
                  style: AppTextStyles.titleSmall.copyWith(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),

                // Price
                Text(
                  CurrencyFormatter.format(price),
                  style: AppTextStyles.price.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
