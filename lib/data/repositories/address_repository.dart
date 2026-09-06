import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/address_model.dart';

class AddressRepository {
  final ApiClient _api = ApiClient.instance;

  Future<List<AddressModel>> getAddresses() async {
    final response = await _api.get(ApiEndpoints.deliveryAddresses);
    final rawData = response.data;

    List<dynamic> list = [];
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map<String, dynamic>) {
      if (rawData['data'] is List) {
        list = rawData['data'];
      }
    }

    return list.map((item) => AddressModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<AddressModel> createAddress({
    required String name,
    required String provinsi,
    required String kabupaten,
    required String kecamatan,
    required String kelurahan,
    required String detail,
  }) async {
    final response = await _api.post(
      ApiEndpoints.deliveryAddresses,
      data: {
        'name': name,
        'provinsi': provinsi,
        'kabupaten': kabupaten,
        'kecamatan': kecamatan,
        'kelurahan': kelurahan,
        'detail': detail,
      },
    );

    final rawData = response.data;
    final dataObj = rawData is Map<String, dynamic> && rawData['data'] is Map<String, dynamic>
        ? rawData['data']
        : rawData;

    return AddressModel.fromJson(dataObj as Map<String, dynamic>);
  }

  Future<bool> updateAddress({
    required String id,
    required String name,
    required String provinsi,
    required String kabupaten,
    required String kecamatan,
    required String kelurahan,
    required String detail,
  }) async {
    final response = await _api.put(
      ApiEndpoints.deliveryAddressDetail(id),
      data: {
        'name': name,
        'provinsi': provinsi,
        'kabupaten': kabupaten,
        'kecamatan': kecamatan,
        'kelurahan': kelurahan,
        'detail': detail,
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteAddress(String id) async {
    final response = await _api.delete(ApiEndpoints.deliveryAddressDetail(id));
    return response.statusCode == 200;
  }
}
