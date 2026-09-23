import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../routes/app_pages.dart';
import '../controllers/payment_detail_controller.dart';

class PaymentDetailView extends StatelessWidget {
  const PaymentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaymentDetailController>(
      builder: (controller) {
        final charge = controller.charge;
        final bank = charge.primaryBank;
        final isQris = charge.paymentType.toLowerCase() == 'qris' || charge.qrCodeUrl != null;
        final isMandiri = charge.billerCode != null && charge.billKey != null;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, size: 22),
              onPressed: () => _confirmExit(context),
            ),
            title: Text('Payment', style: AppTextStyles.titleMedium),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Countdown Timer Banner
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.warningBg,
                    borderRadius: AppSpacing.roundedXl,
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.timer_outlined, color: AppColors.warning, size: 24),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Complete payment within',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              controller.formattedRemainingTime,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Total Bill Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.roundedXl,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Payment', style: AppTextStyles.bodySmall),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(controller.totalAmount),
                            style: AppTextStyles.priceLarge.copyWith(fontSize: 20),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => controller.copyToClipboard(
                          controller.totalAmount.toString(),
                          'Total payment',
                        ),
                        icon: const Icon(Icons.copy_rounded, size: 20, color: AppColors.accent),
                        tooltip: 'Copy amount',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Payment Destination Card (VA / Mandiri / QRIS)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.roundedXl,
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isQris ? 'QRIS Payment' : '$bank Virtual Account',
                            style: AppTextStyles.titleSmall,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: AppSpacing.roundedPill,
                            ),
                            child: Text(
                              bank,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 28),

                      // QRIS View
                      if (isQris) ...[
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Scan this QR Code with your payment app',
                                style: AppTextStyles.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              if (charge.qrCodeUrl != null)
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: AppSpacing.roundedLg,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: AppImage(
                                    imageUrl: charge.qrCodeUrl!,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              else
                                const Text('QR Code unavailable'),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Supports GoPay, OVO, DANA, ShopeePay, BCA, Livin, etc.',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ]
                      // Mandiri Bill View
                      else if (isMandiri) ...[
                        _buildCopyItem(
                          context,
                          label: 'Company Code (Biller Code)',
                          value: charge.billerCode ?? '',
                          onCopy: () => controller.copyToClipboard(charge.billerCode ?? '', 'Company Code'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildCopyItem(
                          context,
                          label: 'Payment Number (Bill Key)',
                          value: charge.billKey ?? '',
                          onCopy: () => controller.copyToClipboard(charge.billKey ?? '', 'Payment Number'),
                        ),
                      ]
                      // Standard Bank Transfer VA View
                      else ...[
                        _buildCopyItem(
                          context,
                          label: 'Virtual Account Number',
                          value: charge.primaryVaNumber,
                          onCopy: () => controller.copyToClipboard(charge.primaryVaNumber, 'Virtual Account Number'),
                          isLarge: true,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Payment Instruction Guides
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.roundedXl,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                        child: Text('Payment Instructions', style: AppTextStyles.titleSmall),
                      ),

                      // Tabs (m-Banking, ATM, Internet Banking)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Row(
                          children: [
                            _buildTabItem(controller, index: 0, label: 'm-Banking'),
                            _buildTabItem(controller, index: 1, label: 'ATM'),
                            _buildTabItem(controller, index: 2, label: 'i-Banking'),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Steps content
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _getInstructions(bank, controller.selectedGuideTab, isQris)
                              .asMap()
                              .entries
                              .map((entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceSecondary,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: AppColors.border),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${entry.key + 1}',
                                              style: AppTextStyles.labelSmall.copyWith(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Text(
                                            entry.value,
                                            style: AppTextStyles.bodySmall.copyWith(height: 1.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),

          // Bottom Action Buttons
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Automatic status checking is active',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    text: 'Check Payment Status',
                    isLoading: controller.isCheckingStatus,
                    onPressed: () => controller.checkStatus(isManual: true),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    text: 'View Order History',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Get.offNamed(Routes.ORDER_HISTORY),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCopyItem(
    BuildContext context, {
    required String label,
    required String value,
    required VoidCallback onCopy,
    bool isLarge = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: isLarge
                      ? AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                        )
                      : AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: AppColors.accent, size: 20),
            onPressed: onCopy,
            tooltip: 'Copy',
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(PaymentDetailController controller, {required int index, required String label}) {
    final isSelected = controller.selectedGuideTab == index;
    return GestureDetector(
      onTap: () => controller.setGuideTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.accent : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  List<String> _getInstructions(String bank, int tabIndex, bool isQris) {
    if (isQris) {
      return [
        'Open your preferred e-Wallet (GoPay, OVO, DANA, ShopeePay) or mobile banking app.',
        'Select "Pay" or "Scan QRIS".',
        'Point your camera at the QR Code displayed above.',
        'Carefully verify the recipient details and transaction amount.',
        'Enter your PIN to complete the payment.',
        'Once successful, return to this app and tap "Check Payment Status".',
      ];
    }

    // Default Bank Virtual Account guides
    if (tabIndex == 0) {
      // m-Banking
      switch (bank) {
        case 'BCA':
          return [
            'Open the BCA mobile app and select "m-BCA".',
            'Select "m-Transfer", then choose "BCA Virtual Account".',
            'Enter the Virtual Account Number displayed above.',
            'Enter the exact payment amount as billed.',
            'Enter your m-BCA PIN and save the transaction receipt.',
          ];
        case 'MANDIRI':
          return [
            'Open the Livin\' by Mandiri app and log in.',
            'Select "Pay", then tap "New Payment".',
            'Choose "Multi Payment" and enter the Company Code shown above.',
            'Enter your Payment Number (Bill Key).',
            'Review the bill details and enter your Livin\' PIN.',
          ];
        case 'BNI':
          return [
            'Open the BNI Mobile Banking app and log in.',
            'Select "Transfer", then choose "Virtual Account Billing".',
            'Select the "New Input" tab and enter the Virtual Account Number.',
            'Confirm the billing details and enter your Transaction Password.',
          ];
        case 'BRI':
          return [
            'Open the BRImo app and log in.',
            'Select "BRIVA", then choose "New Payment".',
            'Enter your BRI Virtual Account Number.',
            'Verify the payment amount and enter your BRImo PIN.',
          ];
        default:
          return [
            'Open your bank\'s mobile banking app.',
            'Navigate to Transfer to Virtual Account.',
            'Enter the Virtual Account Number shown above.',
            'Confirm the amount and complete the transaction with your PIN.',
          ];
      }
    } else if (tabIndex == 1) {
      // ATM
      return [
        'Insert your ATM card and enter your PIN at the ATM.',
        'Select "Other Transactions" > "Transfer" > "To Virtual Account".',
        'Enter the Virtual Account Number displayed on the app screen.',
        'Confirm that the recipient name and amount match.',
        'Press "Yes" to process the payment and keep the receipt.',
      ];
    } else {
      // Internet Banking
      return [
        'Open your bank\'s Internet Banking website and log in.',
        'Select "Fund Transfer" and choose "Transfer to Virtual Account".',
        'Enter the Virtual Account Number shown in the app.',
        'Verify the payment details and authorize the transaction with token/SMS OTP.',
      ];
    }
  }

  void _confirmExit(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedXl),
        title: Text('Leave Payment?', style: AppTextStyles.titleSmall),
        content: Text(
          'Your order has been saved in Order History. You can complete the payment anytime before it expires.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // close dialog
              Get.offAllNamed(Routes.HOME); // return to home
            },
            child: Text('Yes, Leave', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
