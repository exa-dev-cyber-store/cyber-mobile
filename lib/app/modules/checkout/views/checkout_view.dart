import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../routes/app_pages.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../select_addresses/controllers/select_addresses_controller.dart';
import '../controllers/checkout_controller.dart';
import '../widget/card_checkout_products.dart';
import '../widget/voucher_card_widget.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order Confirmation', style: AppTextStyles.titleMedium),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Address Card
            GetBuilder<SelectAddressesController>(
              builder: (addrCtrl) {
                final address = addrCtrl.selectedAddress;
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.roundedXl,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 18, color: AppColors.accent),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Shipping Address',
                                style: AppTextStyles.labelLarge
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () =>
                                Get.toNamed(Routes.SELECT_ADDRESSES),
                            child: Text(
                                address != null ? 'Change' : 'Select Address'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (addrCtrl.isLoading) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Loading delivery address...',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ] else if (addrCtrl.hasError && address == null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  size: 16, color: AppColors.error),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  addrCtrl.errorMessage ??
                                      'Failed to load address.',
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.error),
                                ),
                              ),
                              InkWell(
                                onTap: () => addrCtrl.getAddress(),
                                borderRadius: AppSpacing.roundedSm,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.refresh_rounded,
                                          size: 14, color: AppColors.accent),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Retry',
                                        style:
                                            AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (address != null) ...[
                        Text(address.name,
                            style: AppTextStyles.labelMedium
                                .copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(address.fullAddress,
                            style:
                                AppTextStyles.bodySmall.copyWith(height: 1.4)),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'No address selected yet.',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textTertiary),
                              ),
                            ),
                            InkWell(
                              onTap: () => addrCtrl.getAddress(),
                              borderRadius: AppSpacing.roundedSm,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.refresh_rounded,
                                        size: 14,
                                        color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Reload',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Order Items
            Text('Order Items', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            GetBuilder<CartController>(
              builder: (controller) => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.products.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  return CardCheckoutProducts(item: controller.products[index]);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Voucher & Promo Section
            Text('Voucher & Promo Code', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            VoucherCardWidget(controller: controller),
            const SizedBox(height: AppSpacing.xl),

            // Payment Method Selection
            Text('Payment Method', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            GetBuilder<CheckoutController>(
              builder: (ctrl) => Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.roundedXl,
                  border: Border.all(color: AppColors.border),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ctrl.paymentMethods.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final method = ctrl.paymentMethods[index];
                    final isSelected = ctrl.selectedPaymentId == method.id;
                    return InkWell(
                      onTap: () => ctrl.setPaymentMethod(method.id),
                      borderRadius: index == 0
                          ? const BorderRadius.vertical(
                              top: Radius.circular(AppSpacing.radiusXl))
                          : index == ctrl.paymentMethods.length - 1
                              ? const BorderRadius.vertical(
                                  bottom: Radius.circular(AppSpacing.radiusXl))
                              : BorderRadius.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accent.withValues(alpha: 0.1)
                                    : AppColors.surfaceSecondary,
                                borderRadius: AppSpacing.roundedMd,
                              ),
                              child: Icon(
                                method.icon,
                                size: 22,
                                color: isSelected
                                    ? AppColors.accent
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method.title,
                                    style: AppTextStyles.labelLarge.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    method.subtitle,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontSize: 11,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accent
                                      : AppColors.border,
                                  width: isSelected ? 6 : 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Payment Summary Breakdown Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedXl,
                border: Border.all(color: AppColors.border),
              ),
              child: GetBuilder<CheckoutController>(
                builder: (ctrl) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment Summary', style: AppTextStyles.titleSmall),
                    const SizedBox(height: AppSpacing.md),
                    _buildRow('Item Subtotal',
                        CurrencyFormatter.format(cartController.totalCart)),
                    const SizedBox(height: AppSpacing.sm),
                    _buildRow('VAT', CurrencyFormatter.format(ctrl.tax)),
                    const SizedBox(height: AppSpacing.sm),
                    _buildRow('Shipping Fee',
                        CurrencyFormatter.format(ctrl.shipping)),
                    if (ctrl.discount > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _buildRow(
                        ctrl.appliedVoucher != null
                            ? 'Voucher Discount (${ctrl.appliedVoucher!.code})'
                            : 'Voucher Discount',
                        '- ${CurrencyFormatter.format(ctrl.discount)}',
                        isDiscount: true,
                      ),
                    ],
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Payment', style: AppTextStyles.titleSmall),
                        Text(
                          CurrencyFormatter.format(ctrl.total),
                          style:
                              AppTextStyles.priceLarge.copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Midtrans Badge
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceTertiary,
                borderRadius: AppSpacing.roundedLg,
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined,
                      size: 20, color: AppColors.accent),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Secure & encrypted payment powered by Midtrans.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ),
      ),

      // Sticky Bottom Pay Bar
      bottomNavigationBar: GetBuilder<CheckoutController>(
        builder: (controller) => Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: SafeArea(
            child: AppButton(
              text: 'Pay Now • ${CurrencyFormatter.format(controller.total)}',
              isLoading: controller.isCheckingOut,
              onPressed: () => controller.checkout(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            color: isDiscount ? AppColors.success : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
