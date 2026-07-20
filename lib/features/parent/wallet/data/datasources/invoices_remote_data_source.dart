import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/features/parent/wallet/data/models/invoice_details_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/invoice_model.dart';

class InvoicesRemoteDataSource {
  final ApiClient _apiClient;

  InvoicesRemoteDataSource(this._apiClient);

  Future<List<InvoiceModel>> getInvoices() async {
    final response = await _apiClient.get(ApiEndpoints.parentInvoices);
    final data = response.data['data'] as List;
    return data.map((e) => InvoiceModel.fromJson(e)).toList();
  }

  Future<InvoiceDetailsModel> getInvoiceDetails(int id) async {
    final response = await _apiClient.get(ApiEndpoints.parentInvoiceDetail(id));
    return InvoiceDetailsModel.fromJson(response.data['data']);
  }
}
