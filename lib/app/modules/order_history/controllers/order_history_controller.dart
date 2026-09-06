import 'package:get/get.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../routes/app_pages.dart';

class OrderHistoryController extends GetxController {
  final OrderRepository _orderRepo = OrderRepository();

  List<OrderModel> orders = [];
  bool loading = true;

  @override
  void onInit() {
    super.onInit();
    getOrders();
  }

  Future<void> getOrders() async {
    loading = true;
    update();

    try {
      orders = await _orderRepo.getOrders();
    } catch (e) {
      AppLogger.e('Error loading order history', e);
      orders = [];
    } finally {
      loading = false;
      update();
    }
  }

  Future<void> payPendingOrder(OrderModel order) async {
    try {
      final statusRes = await _orderRepo.checkPaymentStatus(order.id);
      if (statusRes.charge != null) {
        Get.toNamed(
          Routes.PAYMENT_DETAIL,
          arguments: {
            'charge': statusRes.charge,
            'orderId': order.id,
            'totalAmount': order.total,
          },
        );
      } else {
        Get.toNamed('/invoice/${order.id}');
      }
    } catch (e) {
      AppLogger.e('Check payment error', e);
      Get.toNamed('/invoice/${order.id}');
    }
  }
}
