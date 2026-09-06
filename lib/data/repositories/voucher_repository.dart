import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/voucher_model.dart';

class VoucherRepository {
  final ApiClient _api = ApiClient.instance;

  Future<List<VoucherModel>> getPublicVouchers() async {
    final response = await _api.get(ApiEndpoints.publicVouchers);
    final rawData = response.data;

    List<dynamic> list = [];
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map<String, dynamic>) {
      if (rawData['data'] is List) {
        list = rawData['data'];
      }
    }

    return list.map((item) => VoucherModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<ValidateVoucherResult> validateVoucher({
    required String code,
    required int subtotal,
  }) async {
    final response = await _api.post(
      ApiEndpoints.validateVoucher,
      data: {
        'code': code.trim().toUpperCase(),
        'subtotal': subtotal,
      },
    );

    final rawData = response.data;
    final message = rawData is Map<String, dynamic> ? (rawData['message']?.toString() ?? '') : '';
    final dataObj = rawData is Map<String, dynamic> && rawData['data'] is Map<String, dynamic>
        ? rawData['data']
        : (rawData is Map<String, dynamic> ? rawData : <String, dynamic>{});

    return ValidateVoucherResult.fromJson(dataObj as Map<String, dynamic>, message: message);
  }
}
