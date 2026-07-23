import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/wallet_model.dart';
import '../models/withdrawal_model.dart';
import '../models/invoice_model.dart';
import '../models/invoice_details_model.dart';

class FinanceRemoteDataSource {
  final ApiClient _apiClient;

  FinanceRemoteDataSource(this._apiClient);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  Future<WalletModel> getWalletBalance() async {
    final response = await _apiClient.get(
      'v1/driver/wallet/balance',
      headers: _authHeader,
    );
    final data = _handleResponse(response.data);
    return WalletModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<List<WithdrawalModel>> getWithdrawals() async {
    final response = await _apiClient.get(
      'v1/driver/withdrawals',
      headers: _authHeader,
    );
    final data = _handleResponse(response.data);
    final rawList = data['data'] as List<dynamic>? ?? [];
    return rawList
        .map((e) => WithdrawalModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Map<String, dynamic>> createWithdrawal(Map<String, dynamic> body) async {
    final response = await _apiClient.post(
      'v1/driver/withdrawals',
      data: body,
      headers: _authHeader,
    );
    return _handleResponse(response.data);
  }

  Future<List<InvoiceModel>> getInvoices() async {
    final response = await _apiClient.get(
      'v1/driver/invoices',
      headers: _authHeader,
    );
    final data = _handleResponse(response.data);
    final rawList = data['data'] as List<dynamic>? ?? [];
    return rawList
        .map((e) => InvoiceModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<InvoiceDetailsModel> getInvoiceDetails(int id) async {
    final response = await _apiClient.get(
      'v1/driver/invoices/$id',
      headers: _authHeader,
    );
    final data = _handleResponse(response.data);
    return InvoiceDetailsModel.fromJson(data);
  }

  Map<String, dynamic> _handleResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'حدث خطأ في الخادم.');
      }
      return data;
    }
    throw const ApiException('استجابة غير متوقعة من الخادم.');
  }
}
