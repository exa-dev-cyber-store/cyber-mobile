import 'package:get/get.dart';

import '../controllers/select_addresses_controller.dart';

class SelectAddressesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelectAddressesController>(
      () => SelectAddressesController(),
      fenix: true,
    );
  }
}
