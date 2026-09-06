import 'package:get/get.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../data/models/address_model.dart';
import '../../../../data/repositories/address_repository.dart';

class SelectAddressesController extends GetxController {
  final AddressRepository _addressRepo = AddressRepository();

  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;
  List<AddressModel> addresses = [];
  String? currentAddressOption;

  @override
  void onInit() {
    super.onInit();
    currentAddressOption = LocalStorageService.instance.selectedAddressId;
    getAddress();
  }

  void selectAddress(String id) {
    currentAddressOption = id;
    LocalStorageService.instance.setSelectedAddressId(id);
    update();
  }

  Future<void> getAddress() async {
    isLoading = true;
    hasError = false;
    errorMessage = null;
    update();

    try {
      addresses = await _addressRepo.getAddresses();
      hasError = false;
      errorMessage = null;

      if (addresses.isNotEmpty) {
        // If current address is null or no longer exists in fetched addresses, default to first address
        if (currentAddressOption == null ||
            !addresses.any((a) => a.id == currentAddressOption)) {
          currentAddressOption = addresses.first.id;
          LocalStorageService.instance.setSelectedAddressId(currentAddressOption!);
        }
      } else {
        currentAddressOption = null;
      }
    } catch (e) {
      AppLogger.e('Error loading delivery addresses', e);
      hasError = true;
      errorMessage = 'Gagal memuat alamat. Periksa koneksi internet Anda.';
      addresses = [];
    } finally {
      isLoading = false;
      update();
    }
  }

  AddressModel? get selectedAddress {
    if (currentAddressOption == null) return null;
    return addresses.firstWhereOrNull((a) => a.id == currentAddressOption);
  }
}
