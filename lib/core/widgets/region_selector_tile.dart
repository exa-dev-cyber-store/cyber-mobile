import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'region_picker_bottom_sheet.dart';

class RegionSelectorTile extends StatelessWidget {
  final String label;
  final String? value;
  final String placeholder;
  final IconData icon;
  final bool isEnabled;
  final bool isLoading;
  final String? disabledHint;
  final VoidCallback? onTap;

  const RegionSelectorTile({
    super.key,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.icon,
    this.isEnabled = true,
    this.isLoading = false,
    this.disabledHint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.trim().isNotEmpty;
    final displayValue = hasValue ? formatWilayahName(value!) : placeholder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isEnabled ? AppColors.textPrimary : AppColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        Material(
          color: isEnabled ? AppColors.surface : AppColors.surfaceSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.roundedLg,
            side: BorderSide(
              color: isEnabled
                  ? (hasValue ? AppColors.accent.withValues(alpha: 0.3) : AppColors.border)
                  : AppColors.borderLight,
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: (isEnabled && !isLoading) ? onTap : null,
            borderRadius: AppSpacing.roundedLg,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isEnabled
                        ? (hasValue ? AppColors.accent : AppColors.textSecondary)
                        : AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      displayValue,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: hasValue
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                        fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                      ),
                    )
                  else
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: isEnabled ? AppColors.textSecondary : AppColors.textTertiary,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (!isEnabled && disabledHint != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 12, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  disabledHint!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
