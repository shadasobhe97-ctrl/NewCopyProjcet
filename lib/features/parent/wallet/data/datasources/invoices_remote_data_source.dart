import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/parent/wallet/data/models/invoice_details_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/invoice_model.dart';

class InvoicesRemoteDataSource {
  final ApiClient _apiClient;

  InvoicesRemoteDataSource(this._apiClient);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  Future<List<InvoiceModel>> getInvoices() async {
    final response = await _apiClient.get(
      ApiEndpoints.parentInvoices,
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل الفواتير.');
      }
    }
    final list = data['data'] as List;
    return list.map((e) => InvoiceModel.fromJson(e)).toList();
  }

  Future<InvoiceDetailsModel> getInvoiceDetails(int id) async {
    final response = await _apiClient.get(
      ApiEndpoints.parentInvoiceDetail(id),
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل تفاصيل الفاتورة.');
      }
    }
    return InvoiceDetailsModel.fromJson(data['data']);
  }
}
