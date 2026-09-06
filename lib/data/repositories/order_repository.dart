import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/midtrans_model.dart';
import '../models/order_model.dart';

class OrderRepository {
  final ApiClient _api = ApiClient.instance;

  Future<MidtransResponseModel> createOrder({
    required int total,
    required int subTotal,
    required int tax,
    required int shipping,
    required int discount,
    required String deliveryAddressId,
  }) async {
    final response = await _api.post(
      ApiEndpoints.orders,
      data: {
        'total': total,
        'subTotal': subTotal,
        'tax': tax,
        'shipping': shipping,
        'discount': discount,
        'deliveryAddress': deliveryAddressId,
      },
    );

    final rawData = response.data;
    final dataObj = rawData is Map<String, dynamic> && rawData['data'] is Map<String, dynamic>
        ? rawData['data']
        : rawData;

    return MidtransResponseModel.fromJson(dataObj as Map<String, dynamic>);
  }

  Future<List<OrderModel>> getOrders() async {
    final response = await _api.get(ApiEndpoints.orders);
    final rawData = response.data;

    List<dynamic> list = [];
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map<String, dynamic>) {
      if (rawData['data'] is List) {
        list = rawData['data'];
      }
    }

    return list.map((item) => OrderModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<ChargeResponseModel> chargeOrder({
    String? orderId,
    String? deliveryAddressId,
    required String paymentType,
    String? bank,
    String? store,
    int? discount,
  }) async {
    final response = await _api.post(
      ApiEndpoints.orderCharge,
      data: {
        if (orderId != null && orderId.isNotEmpty) 'orderId': orderId,
        if (deliveryAddressId != null && deliveryAddressId.isNotEmpty) 'deliveryAddress': deliveryAddressId,
        'payment_type': paymentType,
        if (bank != null && bank.isNotEmpty) 'bank': bank,
        if (store != null && store.isNotEmpty) 'store': store,
        if (discount != null && discount > 0) 'discount': discount,
      },
    );

    final rawData = response.data;
    final dataObj = rawData is Map<String, dynamic> && rawData['data'] is Map<String, dynamic>
        ? rawData['data']
        : rawData;

    return ChargeResponseModel.fromJson(dataObj as Map<String, dynamic>);
  }

  Future<PaymentStatusResponseModel> checkPaymentStatus(String orderId) async {
    final response = await _api.get(ApiEndpoints.orderStatus(orderId));
    final rawData = response.data;
    final dataObj = rawData is Map<String, dynamic> && rawData['data'] is Map<String, dynamic>
        ? rawData['data']
        : rawData;

    return PaymentStatusResponseModel.fromJson(dataObj as Map<String, dynamic>);
  }
}
