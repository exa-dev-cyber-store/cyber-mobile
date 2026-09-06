import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../routes/app_pages.dart';
import '../controllers/address_controller.dart';

class AddressView extends GetView<AddressController> {
  AddressView({super.key});

  final addressController = Get.find<AddressController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Buku Alamat', style: AppTextStyles.titleMedium),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => addressController.getAddress(),
        child: GetBuilder<AddressController>(
          init: addressController,
          builder: (controller) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.addresses.isEmpty) {
              return EmptyStateView(
                icon: Icons.location_off_outlined,
                title: 'Belum Ada Alamat',
                description: 'Simpan alamat pengiriman untuk mempercepat proses belanja Anda.',
                buttonText: 'Tambah Alamat',
                onButtonPressed: () => Get.toNamed(Routes.CREATE_ADDRESS),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: controller.addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final address = controller.addresses[index];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.roundedXl,
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 18, color: AppColors.accent),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                address.name,
                                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => Get.toNamed(
                                  '/edit-address/${address.id}',
                                  arguments: address,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _confirmDelete(controller, address.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${address.detail}, ${address.kelurahan}, ${address.kecamatan}, ${address.kabupaten}, ${address.provinsi}',
                        style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: SafeArea(
          child: AppButton(
            text: 'Tambah Alamat Baru',
            prefixIcon: const Icon(Icons.add_rounded, size: 20, color: AppColors.textLight),
            onPressed: () => Get.toNamed(Routes.CREATE_ADDRESS),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(AddressController controller, String addressId) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedXl),
        title: Text('Hapus Alamat?', style: AppTextStyles.titleMedium),
        content: Text(
          'Apakah Anda yakin ingin menghapus alamat ini?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAddress(addressId);
            },
            child: Text(
              'Hapus',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
