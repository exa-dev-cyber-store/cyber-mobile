import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/voucher_model.dart';
import '../controllers/checkout_controller.dart';

class VoucherBottomSheet extends StatefulWidget {
  final CheckoutController controller;
  final ScrollController? scrollController;

  const VoucherBottomSheet({
    super.key,
    required this.controller,
    this.scrollController,
  });

  static Future<void> show(
      BuildContext context, CheckoutController controller) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (ctx) => AnimatedPadding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          child: VoucherBottomSheet(
            controller: controller,
          ),
        ),
      ),
    );
  }

  @override
  State<VoucherBottomSheet> createState() => _VoucherBottomSheetState();
}

class _VoucherBottomSheetState extends State<VoucherBottomSheet> {
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Voucher & Promo', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        'Gunakan promo terbaik untuk pesananmu',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 22, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 16),

          // Pinned Promo Code Input Section
          GetBuilder<CheckoutController>(
            builder: (ctrl) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Punya Kode Promo?',
                      style: AppTextStyles.labelLarge
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSecondary,
                              borderRadius: AppSpacing.roundedMd,
                              border: Border.all(
                                color: ctrl.voucherErrorMessage != null
                                    ? AppColors.error
                                    : AppColors.border,
                              ),
                            ),
                            child: TextField(
                              controller: _codeController,
                              textCapitalization: TextCapitalization.characters,
                              style: AppTextStyles.labelLarge.copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                              decoration: InputDecoration(
                                hintText: 'CONTOH: CYBER20',
                                hintStyle: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textTertiary,
                                  fontFamily: 'sans-serif',
                                  letterSpacing: 0,
                                ),
                                prefixIcon: const Icon(
                                  Icons.local_offer_outlined,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SizedBox(
                          height: 46,
                          child: Material(
                            color: ctrl.isValidatingVoucher
                                ? AppColors.surfaceSecondary
                                : AppColors.primary,
                            borderRadius: AppSpacing.roundedMd,
                            child: InkWell(
                              borderRadius: AppSpacing.roundedMd,
                              onTap: ctrl.isValidatingVoucher
                                  ? null
                                  : () async {
                                      final success = await ctrl
                                          .applyVoucherCode(_codeController.text);
                                      if (success && context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg),
                                alignment: Alignment.center,
                                child: ctrl.isValidatingVoucher
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : const Text(
                                        'Terapkan',
                                        style: TextStyle(
                                          color: AppColors.textLight,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (ctrl.voucherErrorMessage != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        ctrl.voucherErrorMessage!,
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.error),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            size: 13, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Punya voucher dari Instagram/TikTok? Masukkan kode rahasianya di atas.',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Section Title: Available Vouchers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Voucher Toko Tersedia',
                          style: AppTextStyles.labelLarge
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceTertiary,
                            borderRadius: AppSpacing.roundedPill,
                          ),
                          child: Text(
                            '${ctrl.availableVouchers.length} Promo',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // Scrollable Voucher List
          Expanded(
            child: GetBuilder<CheckoutController>(
              builder: (ctrl) {
                if (ctrl.isLoadingVouchers) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xxl),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (ctrl.availableVouchers.isEmpty) {
                  return SingleChildScrollView(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: AppSpacing.roundedLg,
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.card_giftcard_outlined,
                              size: 36, color: AppColors.textTertiary),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Belum ada promo publik saat ini',
                            style: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  itemCount: ctrl.availableVouchers.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final voucher = ctrl.availableVouchers[index];
                    return _buildVoucherCard(context, ctrl, voucher);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherCard(
      BuildContext context, CheckoutController ctrl, VoucherModel voucher) {
    final isApplied = ctrl.appliedVoucher?.code == voucher.code;
    final isEligible = ctrl.subTotal >= voucher.minPurchase;

    return Container(
      decoration: BoxDecoration(
        color: isApplied ? const Color(0xFFE8F5E9) : AppColors.surface,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(
          color: isApplied ? const Color(0xFFA5D6A7) : AppColors.border,
          width: isApplied ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left icon tag
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isApplied
                    ? const Color(0xFFC8E6C9)
                    : AppColors.surfaceSecondary,
                borderRadius: AppSpacing.roundedMd,
              ),
              child: Icon(
                Icons.confirmation_number_outlined,
                size: 24,
                color:
                    isApplied ? const Color(0xFF2E7D32) : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Middle voucher info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceTertiary,
                          borderRadius: AppSpacing.roundedSm,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          voucher.code,
                          style: AppTextStyles.labelSmall.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Text(
                        voucher.formattedDiscountText,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF2E7D32),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    voucher.title,
                    style: AppTextStyles.labelMedium
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    voucher.formattedRequirementText,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: isEligible
                          ? AppColors.textSecondary
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Right Action Button
            if (isApplied)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8E6C9),
                  borderRadius: AppSpacing.roundedPill,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded,
                        size: 14, color: Color(0xFF2E7D32)),
                    SizedBox(width: 3),
                    Text(
                      'Dipakai',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEligible
                      ? AppColors.primary
                      : AppColors.surfaceSecondary,
                  foregroundColor:
                      isEligible ? AppColors.textLight : AppColors.textTertiary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.roundedPill),
                  elevation: 0,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: isEligible
                    ? () async {
                        await ctrl.applyVoucher(voucher);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    : null,
                child: Text(
                  'Gunakan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isEligible
                        ? AppColors.textLight
                        : AppColors.textTertiary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
