import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../controllers/checkout_controller.dart';
import 'voucher_bottom_sheet.dart';

class VoucherCardWidget extends StatelessWidget {
  final CheckoutController controller;

  const VoucherCardWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(
      builder: (ctrl) {
        final applied = ctrl.appliedVoucher;

        if (applied != null) {
          // Card state when voucher is active
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F4),
              borderRadius: AppSpacing.roundedXl,
              border: Border.all(color: const Color(0xFFA5D6A7), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFC8E6C9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Voucher Aktif Terpasang',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: const Color(0xFF2E7D32),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    // Change / Remove buttons
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => VoucherBottomSheet.show(context, ctrl),
                      child: Text(
                        'Ganti',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => ctrl.removeVoucher(),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: AppSpacing.roundedSm,
                                  border: Border.all(color: const Color(0xFFA5D6A7)),
                                ),
                                child: Text(
                                  applied.code,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1B5E20),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                applied.formattedDiscountText,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: const Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            applied.title,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '- ${CurrencyFormatter.format(ctrl.discount)}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: const Color(0xFF2E7D32),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        // Card state when NO voucher is applied
        final promoCount = ctrl.availableVouchers.length;
        return InkWell(
          onTap: () => VoucherBottomSheet.show(context, ctrl),
          borderRadius: AppSpacing.roundedXl,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSpacing.roundedXl,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: AppSpacing.roundedMd,
                  ),
                  child: const Icon(
                    Icons.local_offer_outlined,
                    size: 20,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voucher & Promo Toko',
                        style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        promoCount > 0
                            ? '$promoCount promo tersedia untukmu'
                            : 'Gunakan kode promo hemat',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: AppSpacing.roundedPill,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Pilih',
                        style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
