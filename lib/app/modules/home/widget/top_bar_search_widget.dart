import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../routes/app_pages.dart';

class TopBarSearchWidget extends StatelessWidget {
  const TopBarSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'searchField',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppSpacing.roundedLg,
          onTap: () => Get.toNamed(Routes.SEARCH_PRODUCT),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSpacing.roundedLg,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 22),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Search iPhone, Mac, AirPods...',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTertiary,
                    borderRadius: AppSpacing.roundedSm,
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppColors.textSecondary, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
