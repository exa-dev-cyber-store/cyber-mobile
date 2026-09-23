import 'package:get/get.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../controllers/notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    final storage = LocalStorageService.instance;
    final repository = NotificationRepository(storage);

    if (!Get.isRegistered<NotificationsController>()) {
      Get.lazyPut<NotificationsController>(
        () => NotificationsController(
          repository: repository,
          storage: storage,
        ),
      );
    }
  }
}
