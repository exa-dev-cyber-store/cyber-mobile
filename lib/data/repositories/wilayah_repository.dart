import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/wilayah_model.dart';

class WilayahRepository {
  final Dio _externalDio = Dio();

  Future<List<WilayahModel>> getProvinces() async {
    final response = await _externalDio.get(ApiEndpoints.provinces);
    final list = response.data as List;
    return list.map((e) => WilayahModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<WilayahModel>> getRegencies(String provinceId) async {
    final response = await _externalDio.get(ApiEndpoints.regencies(provinceId));
    final list = response.data as List;
    return list.map((e) => WilayahModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<WilayahModel>> getDistricts(String regencyId) async {
    final response = await _externalDio.get(ApiEndpoints.districts(regencyId));
    final list = response.data as List;
    return list.map((e) => WilayahModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<WilayahModel>> getVillages(String districtId) async {
    final response = await _externalDio.get(ApiEndpoints.villages(districtId));
    final list = response.data as List;
    return list.map((e) => WilayahModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
