import 'package:get/get.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../notifications/controllers/notifications_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      CartController(),
      permanent: true,
    );

    if (!Get.isRegistered<NotificationsController>()) {
      final storage = LocalStorageService.instance;
      final repository = NotificationRepository(storage);
      Get.put(
        NotificationsController(repository: repository, storage: storage),
        permanent: true,
      );
    }
  }
}
