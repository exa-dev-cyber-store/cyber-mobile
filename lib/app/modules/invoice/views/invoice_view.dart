import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../routes/app_pages.dart';
import '../controllers/invoice_controller.dart';

class InvoiceView extends GetView<InvoiceController> {
  const InvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final InvoiceController invoiceController = Get.find<InvoiceController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Invoice Pesanan', style: AppTextStyles.titleMedium),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          GetBuilder<InvoiceController>(
            builder: (controller) {
              if (controller.invoice == null) return const SizedBox();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share_outlined, size: 20),
                    tooltip: 'Bagikan Faktur',
                    onPressed: controller.isPrinting ? null : () => controller.shareInvoice(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.print_outlined, size: 22),
                    tooltip: 'Cetak Faktur',
                    onPressed: controller.isPrinting ? null : () => controller.printInvoice(),
                  ),
                  const SizedBox(width: 4),
                ],
              );
            },
          ),
        ],
      ),
      body: GetBuilder<InvoiceController>(
        init: invoiceController,
        builder: (controller) {
          if (controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final invoice = controller.invoice;
          if (invoice == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: AppSpacing.md),
                  Text('Invoice tidak ditemukan', style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    text: 'Kembali ke Riwayat Pesanan',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Get.offNamed(Routes.ORDER_HISTORY),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                // Digital Receipt Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.roundedXl,
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Order ID & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('No. Pesanan', style: AppTextStyles.bodySmall),
                              const SizedBox(height: 2),
                              Text(
                                '#${invoice.order.id.length > 10 ? invoice.order.id.substring(0, 10).toUpperCase() : invoice.order.id}',
                                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          StatusBadge(status: invoice.statusPayment),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        DateFormatter.formatFull(invoice.order.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                      ),
                      const Divider(height: 32),

                      // Customer Info
                      Text('Informasi Pelanggan', style: AppTextStyles.titleSmall),
                      const SizedBox(height: AppSpacing.sm),
                      _buildReceiptRow('Nama', invoice.user.name),
                      const SizedBox(height: AppSpacing.xs),
                      _buildReceiptRow('Email', invoice.user.email),
                      const Divider(height: 32),

                      // Delivery Address
                      Text('Alamat Pengiriman', style: AppTextStyles.titleSmall),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        invoice.deliveryAddress.name,
                        style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        invoice.deliveryAddress.fullAddress,
                        style: AppTextStyles.bodySmall.copyWith(height: 1.4),
                      ),
                      const Divider(height: 32),

                      // Itemized List
                      Text('Rincian Item', style: AppTextStyles.titleSmall),
                      const SizedBox(height: AppSpacing.sm),
                      ...invoice.order.orderItems.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: AppTextStyles.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text('${item.quantity}x ', style: AppTextStyles.bodySmall),
                              Text(
                                CurrencyFormatter.format(item.price * item.quantity),
                                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 32),

                      // Financial Breakdown
                      _buildReceiptRow('Subtotal', CurrencyFormatter.format(invoice.subtotal)),
                      const SizedBox(height: AppSpacing.xs),
                      _buildReceiptRow('Pajak PPN', CurrencyFormatter.format(invoice.tax)),
                      const SizedBox(height: AppSpacing.xs),
                      _buildReceiptRow('Ongkos Kirim', CurrencyFormatter.format(invoice.shipping)),
                      if (invoice.discount > 0) ...[
                        const SizedBox(height: AppSpacing.xs),
                        _buildReceiptRow('Diskon', '- ${CurrencyFormatter.format(invoice.discount)}', isHighlight: true),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Pembayaran', style: AppTextStyles.titleSmall),
                          Text(
                            CurrencyFormatter.format(invoice.total),
                            style: AppTextStyles.priceLarge.copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                      const Divider(height: 32),

                      // Status Delivery
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Status Pengiriman', style: AppTextStyles.bodyMedium),
                          StatusBadge(status: invoice.statusDelivery),
                        ],
                      ),
                    ],
                  ),
                ),

                // Pay Now button if pending
                if (invoice.statusPayment.toLowerCase() == 'pending' &&
                    invoice.order.urlRedirect != null &&
                    invoice.order.urlRedirect!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    text: 'Selesaikan Pembayaran Sekarang',
                    prefixIcon: const Icon(Icons.payment_rounded, color: AppColors.textLight, size: 20),
                    onPressed: () {
                      Get.toNamed(
                        Routes.SNAP_WEBVIEW,
                        arguments: {
                          'redirectUrl': invoice.order.urlRedirect,
                        },
                      );
                    },
                  ),
                ],

                // Action Buttons: Print & Share Invoice
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: 'Cetak / Unduh PDF',
                  isLoading: controller.isPrinting,
                  prefixIcon: const Icon(Icons.print_rounded, color: AppColors.textLight, size: 20),
                  onPressed: () => controller.printInvoice(),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  text: 'Bagikan Dokumen Faktur',
                  variant: AppButtonVariant.outline,
                  prefixIcon: const Icon(Icons.share_rounded, size: 18),
                  onPressed: () => controller.shareInvoice(),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  text: 'Kembali ke Beranda',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Get.offAllNamed(Routes.HOME),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            color: isHighlight ? AppColors.success : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
