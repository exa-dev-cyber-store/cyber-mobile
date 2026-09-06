import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final ApiClient _api = ApiClient.instance;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _api.get(ApiEndpoints.categories);
    final rawData = response.data;

    List<dynamic> list = [];
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map<String, dynamic>) {
      if (rawData['data'] is List) {
        list = rawData['data'];
      } else if (rawData['categories'] is List) {
        list = rawData['categories'];
      }
    }

    return list.map((item) => CategoryModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}
