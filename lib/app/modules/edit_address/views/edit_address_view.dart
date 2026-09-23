import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/region_picker_bottom_sheet.dart';
import '../../../../core/widgets/region_selector_tile.dart';
import '../controllers/edit_address_controller.dart';

class EditAddressView extends GetView<EditAddressController> {
  const EditAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    final EditAddressController controller = Get.find<EditAddressController>();

    return GetBuilder<EditAddressController>(
      init: controller,
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Update Address', style: AppTextStyles.titleMedium),
            centerTitle: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Get.back(),
            ),
            actions: [
              if (!ctrl.isLoading)
                IconButton(
                  tooltip: 'Delete Address',
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
                  onPressed: () => ctrl.confirmDeleteAddress(),
                ),
            ],
          ),
          body: ctrl.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppSpacing.roundedXl,
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Address / Recipient Label
                        AppTextField(
                          controller: ctrl.nameController,
                          label: 'Address / Recipient Label',
                          hint: 'e.g. Home, Office',
                          prefixIcon: const Icon(
                            Icons.bookmark_border_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Provinsi
                        RegionSelectorTile(
                          label: 'Province',
                          value: ctrl.provinceController.text,
                          placeholder: 'Select Province',
                          icon: Icons.map_outlined,
                          isLoading: ctrl.isLoadingProvince,
                          isEnabled: !ctrl.isLoadingProvince,
                          onTap: () async {
                            final selected = await showRegionPicker(
                              context,
                              title: 'Select Province',
                              items: ctrl.provinces,
                              selectedName: ctrl.provinceController.text,
                            );
                            if (selected != null) {
                              await ctrl.onSelectProvince(selected);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Kota / Kabupaten
                        RegionSelectorTile(
                          label: 'City / Regency',
                          value: ctrl.kotaController.text,
                          placeholder: ctrl.isLoadingKota
                              ? 'Loading Cities...'
                              : (ctrl.provinceController.text.isEmpty
                                  ? 'Select a province first'
                                  : 'Select City / Regency'),
                          icon: Icons.location_city_outlined,
                          isEnabled: ctrl.provinceController.text.isNotEmpty,
                          isLoading: ctrl.isLoadingKota,
                          disabledHint: 'Select a province first',
                          onTap: () async {
                            final selected = await showRegionPicker(
                              context,
                              title: 'Select City / Regency',
                              items: ctrl.kota,
                              selectedName: ctrl.kotaController.text,
                            );
                            if (selected != null) {
                              await ctrl.onSelectKota(selected);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Kecamatan
                        RegionSelectorTile(
                          label: 'District',
                          value: ctrl.kecController.text,
                          placeholder: ctrl.isLoadingKec
                              ? 'Loading Districts...'
                              : (ctrl.kotaController.text.isEmpty
                                  ? 'Select a city first'
                                  : 'Select District'),
                          icon: Icons.holiday_village_outlined,
                          isEnabled: ctrl.kotaController.text.isNotEmpty,
                          isLoading: ctrl.isLoadingKec,
                          disabledHint: 'Select a city first',
                          onTap: () async {
                            final selected = await showRegionPicker(
                              context,
                              title: 'Select District',
                              items: ctrl.kec,
                              selectedName: ctrl.kecController.text,
                            );
                            if (selected != null) {
                              await ctrl.onSelectKec(selected);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Kelurahan / Desa
                        RegionSelectorTile(
                          label: 'Subdistrict / Village',
                          value: ctrl.kelController.text,
                          placeholder: ctrl.isLoadingKel
                              ? 'Loading Subdistricts...'
                              : (ctrl.kecController.text.isEmpty
                                  ? 'Select a district first'
                                  : 'Select Subdistrict / Village'),
                          icon: Icons.home_work_outlined,
                          isEnabled: ctrl.kecController.text.isNotEmpty,
                          isLoading: ctrl.isLoadingKel,
                          disabledHint: 'Select a district first',
                          onTap: () async {
                            final selected = await showRegionPicker(
                              context,
                              title: 'Select Subdistrict / Village',
                              items: ctrl.kel,
                              selectedName: ctrl.kelController.text,
                            );
                            if (selected != null) {
                              ctrl.onSelectKel(selected);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Full Street Address Details
                        AppTextField(
                          controller: ctrl.detailController,
                          label: 'Detailed Street Address',
                          hint: 'Street name, building/house number, unit, landmark',
                          maxLines: 3,
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Tombol Perbarui
                        AppButton(
                          text: 'Update Address',
                          isLoading: ctrl.isLoadingUpdate,
                          onPressed: () => ctrl.updateAddress(),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
