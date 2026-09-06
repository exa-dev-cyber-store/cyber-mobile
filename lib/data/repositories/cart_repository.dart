import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/cart_model.dart';

class CartRepository {
  final ApiClient _api = ApiClient.instance;

  Future<List<CartItemModel>> getCart() async {
    final response = await _api.get(ApiEndpoints.cart);
    final rawData = response.data;

    List<dynamic> list = [];
    if (rawData is Map<String, dynamic>) {
      final dataObj = rawData['data'] is Map<String, dynamic> ? rawData['data'] : rawData;
      if (dataObj['products'] is List) {
        list = dataObj['products'];
      }
    } else if (rawData is List) {
      list = rawData;
    }

    return list.map((item) => CartItemModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<bool> addToCart({required String productId, int quantity = 1}) async {
    final response = await _api.post(
      ApiEndpoints.cart,
      data: {
        'productId': productId,
        'quantity': quantity,
      },
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> reduceCart({required String productId}) async {
    final response = await _api.post(
      '${ApiEndpoints.cart}/reduce',
      data: {'productId': productId},
    );
    return response.statusCode == 200;
  }

  Future<bool> removeFromCart({required String productId}) async {
    final response = await _api.post(
      '${ApiEndpoints.cart}/remove',
      data: {'productId': productId},
    );
    return response.statusCode == 200;
  }
}
