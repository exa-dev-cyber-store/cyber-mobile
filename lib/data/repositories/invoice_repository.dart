import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/invoice_model.dart';

class InvoiceRepository {
  final ApiClient _api = ApiClient.instance;

  Future<InvoiceModel> getInvoice(String id) async {
    final response = await _api.get(ApiEndpoints.invoice(id));
    final rawData = response.data;

    final dataObj = rawData is Map<String, dynamic> && rawData['data'] is Map<String, dynamic>
        ? rawData['data']
        : rawData;

    return InvoiceModel.fromJson(dataObj as Map<String, dynamic>);
  }
}
