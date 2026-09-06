import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/wilayah_model.dart';
import '../../../../data/repositories/address_repository.dart';
import '../../../../data/repositories/wilayah_repository.dart';
import '../../address/controllers/address_controller.dart';
import '../../select_addresses/controllers/select_addresses_controller.dart';

class CreateAddressController extends GetxController {
  final AddressRepository _addressRepo = AddressRepository();
  final WilayahRepository _wilayahRepo = WilayahRepository();

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
  bool isSubmit = false;

  @override
  void onInit() {
    super.onInit();
    getProvinces();
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

  Future<void> createAddress() async {
    if (nameController.text.trim().isEmpty ||
        provinceController.text.trim().isEmpty ||
        kotaController.text.trim().isEmpty ||
        kecController.text.trim().isEmpty ||
        kelController.text.trim().isEmpty ||
        detailController.text.trim().isEmpty) {
      AppSnackbar.warning('Semua bidang alamat wajib diisi.');
      return;
    }

    isSubmit = true;
    update();

    try {
      await _addressRepo.createAddress(
        name: nameController.text.trim(),
        provinsi: provinceController.text.trim(),
        kabupaten: kotaController.text.trim(),
        kecamatan: kecController.text.trim(),
        kelurahan: kelController.text.trim(),
        detail: detailController.text.trim(),
      );

      // Refresh listeners
      if (Get.isRegistered<SelectAddressesController>()) {
        await Get.find<SelectAddressesController>().getAddress();
      }
      if (Get.isRegistered<AddressController>()) {
        await Get.find<AddressController>().getAddress();
      }

      Get.back();
      AppSnackbar.success('Alamat baru berhasil ditambahkan.');
    } catch (e) {
      AppLogger.e('Error creating address', e);
      AppSnackbar.error('Terjadi kesalahan saat menyimpan alamat.');
    } finally {
      isSubmit = false;
      update();
    }
  }

  Future<void> getProvinces() async {
    isLoadingProvince = true;
    update();
    try {
      provinces = await _wilayahRepo.getProvinces();
    } catch (e) {
      AppLogger.e('Error fetching provinces', e);
    } finally {
      isLoadingProvince = false;
      update();
    }
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
}
