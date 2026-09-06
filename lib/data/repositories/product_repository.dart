import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../models/product_like_model.dart';
import '../models/product_model.dart';

class ProductRepository {
  final ApiClient _api = ApiClient.instance;

  Future<PaginatedResult<ProductModel>> getProducts({
    int limit = 8,
    int skip = 0,
    String category = '',
    String q = '',
    CancelToken? cancelToken,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      if (skip > 0) 'skip': skip,
      if (category.isNotEmpty) 'category': category,
      if (q.isNotEmpty) 'q': q,
    };

    final response = await _api.get(
      ApiEndpoints.products,
      queryParameters: queryParams,
      cancelToken: cancelToken,
    );

    final rawData = response.data;
    List<dynamic> productsList = [];
    int totalCount = 0;

    if (rawData is Map<String, dynamic>) {
      final dataObj = rawData['data'] is Map<String, dynamic> ? rawData['data'] : rawData;
      if (dataObj['products'] is List) {
        productsList = dataObj['products'];
      }
      totalCount = (dataObj['count'] as num?)?.toInt() ?? productsList.length;
    }

    final items = productsList
        .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
        .toList();

    return PaginatedResult(
      items: items,
      total: totalCount,
    );
  }

  Future<ProductModel> getProductDetail(String id) async {
    final response = await _api.get(ApiEndpoints.productDetail(id));
    final rawData = response.data;

    Map<String, dynamic> item = {};
    if (rawData is Map<String, dynamic>) {
      if (rawData['data'] is Map<String, dynamic>) {
        item = rawData['data'];
      } else {
        item = rawData;
      }
    }

    return ProductModel.fromJson(item);
  }

  Future<List<ProductLikeModel>> getLikes() async {
    final response = await _api.get(ApiEndpoints.likes);
    final rawData = response.data;

    List<dynamic> list = [];
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map<String, dynamic> && rawData['data'] is List) {
      list = rawData['data'];
    }

    return list.map((item) => ProductLikeModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<bool> toggleLike(String productId) async {
    final response = await _api.post(
      ApiEndpoints.likes,
      data: {'productId': productId},
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
