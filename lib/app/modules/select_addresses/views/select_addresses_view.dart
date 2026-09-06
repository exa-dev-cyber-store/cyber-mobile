import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../routes/app_pages.dart';
import '../controllers/select_addresses_controller.dart';

class SelectAddressesView extends GetView<SelectAddressesController> {
  const SelectAddressesView({super.key});

  @override
  Widget build(BuildContext context) {
    final SelectAddressesController controller = Get.find<SelectAddressesController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Pilih Alamat Pengiriman', style: AppTextStyles.titleMedium),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined, color: AppColors.textPrimary),
            onPressed: () => Get.toNamed(Routes.CREATE_ADDRESS, arguments: {'isEdit': false}),
          ),
        ],
      ),
      body: GetBuilder<SelectAddressesController>(
        init: controller,
        builder: (ctrl) {
          if (ctrl.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ctrl.hasError) {
            return EmptyStateView(
              icon: Icons.wifi_off_rounded,
              title: 'Gagal Memuat Alamat',
              description: ctrl.errorMessage ?? 'Terjadi kendala saat menghubungkan ke server.',
              buttonText: 'Coba Lagi',
              onButtonPressed: () => ctrl.getAddress(),
            );
          }

          if (ctrl.addresses.isEmpty) {
            return EmptyStateView(
              icon: Icons.location_off_outlined,
              title: 'Belum Ada Alamat',
              description: 'Tambahkan alamat pengiriman untuk melanjutkan pemesanan produk Apple Anda.',
              buttonText: 'Tambah Alamat',
              onButtonPressed: () => Get.toNamed(Routes.CREATE_ADDRESS, arguments: {'isEdit': false}),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: ctrl.addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final address = ctrl.addresses[index];
              final isSelected = ctrl.currentAddressOption == address.id;

              return InkWell(
                borderRadius: AppSpacing.roundedXl,
                onTap: () => ctrl.selectAddress(address.id),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.roundedXl,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selection indicator
                      Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.textTertiary,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded, size: 14, color: AppColors.textLight)
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.md),

                      // Address info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address.name,
                              style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              address.fullAddress,
                              style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      // Bottom confirmation bar
      bottomNavigationBar: GetBuilder<SelectAddressesController>(
        builder: (ctrl) {
          if (ctrl.addresses.isEmpty) return const SizedBox();

          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: SafeArea(
              child: AppButton(
                text: 'Pilih & Lanjut ke Pembayaran',
                onPressed: () {
                  if (ctrl.currentAddressOption == null) {
                    AppSnackbar.warning('Silakan pilih alamat pengiriman terlebih dahulu.');
                    return;
                  }
                  if (Get.previousRoute == Routes.CHECKOUT) {
                    Get.back();
                  } else {
                    Get.toNamed(Routes.CHECKOUT);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
