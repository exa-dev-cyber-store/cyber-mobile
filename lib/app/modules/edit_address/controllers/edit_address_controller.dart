import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/address_model.dart';
import '../../../../data/models/wilayah_model.dart';
import '../../../../data/repositories/address_repository.dart';
import '../../../../data/repositories/wilayah_repository.dart';
import '../../address/controllers/address_controller.dart';
import '../../select_addresses/controllers/select_addresses_controller.dart';

class EditAddressController extends GetxController {
  final AddressRepository _addressRepo = AddressRepository();
  final WilayahRepository _wilayahRepo = WilayahRepository();

  bool isLoading = true;
  bool isLoadingUpdate = false;
  bool isDeleting = false;

  AddressModel? address;
  String addressId = '';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController kotaController = TextEditingController();
  final TextEditingController kecController = TextEditingController();
  final TextEditingController kelController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  List<WilayahModel> provinces = [];
  List<WilayahModel> kota = [];
  List<WilayahModel> kec = [];
  List<WilayahModel> kel = [];

  WilayahModel? selectedProvince;
  WilayahModel? selectedKota;
  WilayahModel? selectedKec;
  WilayahModel? selectedKel;

  bool isLoadingProvince = true;
  bool isLoadingKota = false;
  bool isLoadingKec = false;
  bool isLoadingKel = false;

  @override
  void onInit() {
    super.onInit();
    addressId = Get.parameters['id']?.toString() ?? '';
    loadInitialData();
  }

  @override
  void onClose() {
    nameController.dispose();
    provinceController.dispose();
    kotaController.dispose();
    kecController.dispose();
    kelController.dispose();
    detailController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    isLoading = true;
    update();

    try {
      if (Get.arguments is AddressModel) {
        address = Get.arguments as AddressModel;
      } else {
        final addresses = await _addressRepo.getAddresses();
        address = addresses.firstWhereOrNull((a) => a.id == addressId);
      }

      if (address != null) {
        nameController.text = address!.name;
        provinceController.text = address!.provinsi;
        kotaController.text = address!.kabupaten;
        kecController.text = address!.kecamatan;
        kelController.text = address!.kelurahan;
        detailController.text = address!.detail;
      }

      provinces = await _wilayahRepo.getProvinces();
      isLoadingProvince = false;
      update();

      // Resolve existing hierarchy in background so sub-regions can be modified
      if (address != null && address!.provinsi.isNotEmpty) {
        final prov = provinces.firstWhereOrNull(
          (p) => p.name.toLowerCase() == address!.provinsi.toLowerCase(),
        );
        if (prov != null) {
          selectedProvince = prov;
          kota = await _wilayahRepo.getRegencies(prov.id);

          final reg = kota.firstWhereOrNull(
            (k) => k.name.toLowerCase() == address!.kabupaten.toLowerCase(),
          );
          if (reg != null) {
            selectedKota = reg;
            kec = await _wilayahRepo.getDistricts(reg.id);

            final dist = kec.firstWhereOrNull(
              (kc) => kc.name.toLowerCase() == address!.kecamatan.toLowerCase(),
            );
            if (dist != null) {
              selectedKec = dist;
              kel = await _wilayahRepo.getVillages(dist.id);

              final vill = kel.firstWhereOrNull(
                (kl) => kl.name.toLowerCase() == address!.kelurahan.toLowerCase(),
              );
              if (vill != null) {
                selectedKel = vill;
              }
            }
          }
        }
      }
    } catch (e) {
      AppLogger.e('Error loading address data', e);
    } finally {
      isLoading = false;
      isLoadingProvince = false;
      update();
    }
  }

  Future<void> onSelectProvince(WilayahModel item) async {
    selectedProvince = item;
    provinceController.text = item.name;
    selectedKota = null;
    selectedKec = null;
    selectedKel = null;
    kotaController.clear();
    kecController.clear();
    kelController.clear();
    kota = [];
    kec = [];
    kel = [];
    update();
    await getKota(id: item.id);
  }

  Future<void> onSelectKota(WilayahModel item) async {
    selectedKota = item;
    kotaController.text = item.name;
    selectedKec = null;
    selectedKel = null;
    kecController.clear();
    kelController.clear();
    kec = [];
    kel = [];
    update();
    await getKec(id: item.id);
  }

  Future<void> onSelectKec(WilayahModel item) async {
    selectedKec = item;
    kecController.text = item.name;
    selectedKel = null;
    kelController.clear();
    kel = [];
    update();
    await getKel(id: item.id);
  }

  void onSelectKel(WilayahModel item) {
    selectedKel = item;
    kelController.text = item.name;
    update();
  }

  Future<void> getKota({required String id}) async {
    isLoadingKota = true;
    kota = [];
    update();

    try {
      kota = await _wilayahRepo.getRegencies(id);
    } catch (e) {
      AppLogger.e('Error fetching regencies', e);
    } finally {
      isLoadingKota = false;
      update();
    }
  }

  Future<void> getKec({required String id}) async {
    isLoadingKec = true;
    kec = [];
    update();

    try {
      kec = await _wilayahRepo.getDistricts(id);
    } catch (e) {
      AppLogger.e('Error fetching districts', e);
    } finally {
      isLoadingKec = false;
      update();
    }
  }

  Future<void> getKel({required String id}) async {
    isLoadingKel = true;
    kel = [];
    update();

    try {
      kel = await _wilayahRepo.getVillages(id);
    } catch (e) {
      AppLogger.e('Error fetching villages', e);
    } finally {
      isLoadingKel = false;
      update();
    }
  }

  Future<void> updateAddress() async {
    if (nameController.text.trim().isEmpty ||
        provinceController.text.trim().isEmpty ||
        kotaController.text.trim().isEmpty ||
        kecController.text.trim().isEmpty ||
        kelController.text.trim().isEmpty ||
        detailController.text.trim().isEmpty) {
      AppSnackbar.warning('Semua bidang wajib diisi.');
      return;
    }

    isLoadingUpdate = true;
    update();

    try {
      final success = await _addressRepo.updateAddress(
        id: addressId,
        name: nameController.text.trim(),
        provinsi: provinceController.text.trim(),
        kabupaten: kotaController.text.trim(),
        kecamatan: kecController.text.trim(),
        kelurahan: kelController.text.trim(),
        detail: detailController.text.trim(),
      );

      if (success) {
        if (Get.isRegistered<AddressController>()) {
          await Get.find<AddressController>().getAddress();
        }
        if (Get.isRegistered<SelectAddressesController>()) {
          await Get.find<SelectAddressesController>().getAddress();
        }
        Get.back();
        AppSnackbar.success('Alamat berhasil diperbarui.');
      }
    } catch (e) {
      AppLogger.e('Error updating address', e);
      AppSnackbar.error('Terjadi kesalahan saat memperbarui alamat.');
    } finally {
      isLoadingUpdate = false;
      update();
    }
  }

  void confirmDeleteAddress() {
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
              executeDeleteAddress();
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

  Future<void> executeDeleteAddress() async {
    isDeleting = true;
    update();

    try {
      final success = await _addressRepo.deleteAddress(addressId);
      if (success) {
        if (Get.isRegistered<AddressController>()) {
          await Get.find<AddressController>().getAddress();
        }
        if (Get.isRegistered<SelectAddressesController>()) {
          await Get.find<SelectAddressesController>().getAddress();
        }
        Get.back();
        AppSnackbar.success('Alamat berhasil dihapus.');
      }
    } catch (e) {
      AppLogger.e('Error deleting address', e);
      AppSnackbar.error('Gagal menghapus alamat.');
    } finally {
      isDeleting = false;
      update();
    }
  }
}
