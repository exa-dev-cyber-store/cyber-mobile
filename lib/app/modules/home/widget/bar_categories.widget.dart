import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../controllers/home_controller.dart';

class BarCategoriesWidget extends StatelessWidget {
  final HomeController homeController;

  const BarCategoriesWidget({super.key, required this.homeController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: homeController.categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isAllSelected = homeController.activeCategory.isEmpty;
            return _buildChip(
              label: 'All',
              isSelected: isAllSelected,
              onTap: () => homeController.selectCategory(''),
            );
          }

          final category = homeController.categories[index - 1];
          final isSelected = homeController.activeCategory == category.name;

          return _buildChip(
            label: category.name,
            isSelected: isSelected,
            onTap: () => homeController.selectCategory(category.name),
          );
        },
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? AppColors.primary : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.roundedPill,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: AppSpacing.roundedPill,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.textLight : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
