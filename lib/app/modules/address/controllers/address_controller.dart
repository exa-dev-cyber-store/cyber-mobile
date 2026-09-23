import 'package:get/get.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/address_model.dart';
import '../../../../data/repositories/address_repository.dart';

class AddressController extends GetxController {
  final AddressRepository _addressRepo = AddressRepository();

  List<AddressModel> addresses = [];
  bool isLoading = false;
  bool isDeleting = false;

  @override
  void onInit() {
    super.onInit();
    getAddress();
  }

  Future<void> getAddress() async {
    isLoading = true;
    update();

    try {
      addresses = await _addressRepo.getAddresses();
    } catch (e) {
      AppLogger.e('Error loading addresses', e);
      addresses = [];
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> deleteAddress(String id) async {
    isDeleting = true;
    update();

    try {
      final success = await _addressRepo.deleteAddress(id);
      if (success) {
        addresses.removeWhere((a) => a.id == id);
        AppSnackbar.success('Delivery address deleted successfully.', title: 'Deleted');
      }
    } catch (e) {
      AppLogger.e('Error deleting address', e);
      AppSnackbar.error('Failed to delete address.', title: 'Error');
    } finally {
      isDeleting = false;
      update();
    }
  }
}
