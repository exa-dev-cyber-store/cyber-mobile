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
            title: Text('Pembayaran', style: AppTextStyles.titleMedium),
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
                              'Selesaikan pembayaran dalam',
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
                          Text('Total Pembayaran', style: AppTextStyles.bodySmall),
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
                          'Total pembayaran',
                        ),
                        icon: const Icon(Icons.copy_rounded, size: 20, color: AppColors.accent),
                        tooltip: 'Salin nominal',
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
                            isQris ? 'Pembayaran QRIS' : '$bank Virtual Account',
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
                                'Pindai Kode QR ini dengan aplikasi pembayaran Anda',
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
                                const Text('QR Code tidak tersedia'),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Mendukung GoPay, OVO, DANA, ShopeePay, BCA, Livin, dll.',
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
                          label: 'Kode Perusahaan (Biller Code)',
                          value: charge.billerCode ?? '',
                          onCopy: () => controller.copyToClipboard(charge.billerCode ?? '', 'Kode Perusahaan'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildCopyItem(
                          context,
                          label: 'Nomor Pembayaran (Bill Key)',
                          value: charge.billKey ?? '',
                          onCopy: () => controller.copyToClipboard(charge.billKey ?? '', 'Nomor Pembayaran'),
                        ),
                      ]
                      // Standard Bank Transfer VA View
                      else ...[
                        _buildCopyItem(
                          context,
                          label: 'Nomor Virtual Account',
                          value: charge.primaryVaNumber,
                          onCopy: () => controller.copyToClipboard(charge.primaryVaNumber, 'Nomor Virtual Account'),
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
                        child: Text('Petunjuk Pembayaran', style: AppTextStyles.titleSmall),
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
                        'Pengecekan otomatis aktif secara berkala',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    text: 'Cek Status Pembayaran',
                    isLoading: controller.isCheckingStatus,
                    onPressed: () => controller.checkStatus(isManual: true),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    text: 'Lihat Riwayat Pesanan',
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
            tooltip: 'Salin',
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
        'Buka aplikasi e-Wallet (GoPay, OVO, Dana, ShopeePay) atau m-Banking pilihan Anda.',
        'Pilih menu "Bayar" atau "Scan QRIS".',
        'Arahkan kamera ke Kode QR yang tertera di atas layar ini.',
        'Periksa nama penerima dan nominal transaksi secara teliti.',
        'Masukkan PIN Anda untuk menyelesaikan pembayaran.',
        'Setelah transaksi berhasil, kembali ke aplikasi dan klik "Cek Status Pembayaran".',
      ];
    }

    // Default Bank Virtual Account guides
    if (tabIndex == 0) {
      // m-Banking
      switch (bank) {
        case 'BCA':
          return [
            'Buka aplikasi BCA mobile dan pilih menu "m-BCA".',
            'Pilih menu "m-Transfer" lalu pilih "BCA Virtual Account".',
            'Masukkan Nomor Virtual Account yang tertera di atas.',
            'Masukkan jumlah pembayaran sesuai tagihan.',
            'Masukkan PIN m-BCA Anda dan simpan bukti transaksi.',
          ];
        case 'MANDIRI':
          return [
            'Buka aplikasi Livin\' by Mandiri dan masuk ke akun Anda.',
            'Pilih menu "Bayar" lalu pilih "Pembayaran Baru".',
            'Pilih "Multi Payment" dan masukkan Kode Perusahaan di atas.',
            'Masukkan Nomor Pembayaran (Bill Key) Anda.',
            'Periksa rincian tagihan lalu masukkan PIN Livin\' Anda.',
          ];
        case 'BNI':
          return [
            'Buka aplikasi BNI Mobile Banking dan login.',
            'Pilih menu "Transfer" lalu pilih "Virtual Account Billing".',
            'Pilih tab "Input Baru" dan masukkan Nomor Virtual Account.',
            'Konfirmasi rincian tagihan dan masukkan Password Transaksi Anda.',
          ];
        case 'BRI':
          return [
            'Buka aplikasi BRImo dan lakukan login.',
            'Pilih menu "BRIVA" lalu pilih "Pembayaran Baru".',
            'Masukkan Nomor Virtual Account BRI Anda.',
            'Periksa jumlah pembayaran dan masukkan PIN BRImo Anda.',
          ];
        default:
          return [
            'Buka aplikasi mobile banking bank Anda.',
            'Pilih menu Transfer ke Rekening Virtual Account.',
            'Masukkan Nomor Virtual Account yang tertera.',
            'Konfirmasi nominal dan selesaikan dengan PIN Anda.',
          ];
      }
    } else if (tabIndex == 1) {
      // ATM
      return [
        'Masukkan kartu ATM dan PIN Anda di mesin ATM.',
        'Pilih menu "Transaksi Lainnya" > "Transfer" > "Ke Rekening Virtual Account".',
        'Masukkan Nomor Virtual Account yang tertera di layar aplikasi.',
        'Pastikan nama dan nominal yang muncul di layar ATM sudah sesuai.',
        'Tekan "Ya" untuk memproses pembayaran dan simpan struk sebagai bukti.',
      ];
    } else {
      // Internet Banking
      return [
        'Buka situs Internet Banking bank Anda dan login.',
        'Pilih menu "Transfer Dana" lalu pilih "Transfer ke Virtual Account".',
        'Masukkan Nomor Virtual Account yang tertera di aplikasi.',
        'Periksa detail pembayaran dan otorisasi transaksi dengan token/SMS OTP.',
      ];
    }
  }

  void _confirmExit(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedXl),
        title: Text('Keluar dari Pembayaran?', style: AppTextStyles.titleSmall),
        content: Text(
          'Pesanan Anda telah tersimpan di Riwayat Pesanan. Anda dapat menyelesaikan pembayaran kapan saja sebelum batas waktu habis.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // close dialog
              Get.offAllNamed(Routes.HOME); // return to home
            },
            child: Text('Ya, Keluar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
