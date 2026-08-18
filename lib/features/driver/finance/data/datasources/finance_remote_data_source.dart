import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/paginated_response.dart';
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

  Future<PaginatedResponse<WithdrawalModel>> getWithdrawals({
    String? status,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{'page': page};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      'v1/driver/withdrawals',
      queryParameters: queryParams,
      headers: _authHeader,
    );
    final data = _handleResponse(response.data);
    return _parsePaginated<WithdrawalModel>(
      data,
      (e) => WithdrawalModel.fromJson(Map<String, dynamic>.from(e as Map)),
    );
  }

  Future<WithdrawalModel> createWithdrawal(Map<String, dynamic> body) async {
    final response = await _apiClient.post(
      'v1/driver/withdrawals',
      data: body,
      headers: _authHeader,
    );
    final data = _handleResponse(response.data);
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return WithdrawalModel.fromJson(responseData);
  }

  Future<PaginatedResponse<InvoiceModel>> getInvoices({
    String? status,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{'page': page};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      'v1/driver/invoices',
      queryParameters: queryParams,
      headers: _authHeader,
    );
    final data = _handleResponse(response.data);
    return _parsePaginated<InvoiceModel>(
      data,
      (e) => InvoiceModel.fromJson(Map<String, dynamic>.from(e as Map)),
    );
  }

  Future<InvoiceDetailsModel> getInvoiceDetails(int id) async {
    final response = await _apiClient.get(
      'v1/driver/invoices/$id',
      headers: _authHeader,
    );
    final data = _handleResponse(response.data);
    return InvoiceDetailsModel.fromJson(data);
  }

  PaginatedResponse<T> _parsePaginated<T>(
    dynamic rawData,
    T Function(dynamic json) fromJson,
  ) {
    List<dynamic> rawList = [];
    int currentPage = 1;
    int lastPage = 1;
    int perPage = 15;

    if (rawData is Map) {
      final map = rawData as Map<String, dynamic>;
      final dataField = map['data'];

      if (dataField is List) {
        rawList = dataField;
      } else if (dataField is Map) {
        rawList = (dataField['data'] as List<dynamic>?) ?? [];
      }

      final pagination = map['pagination'] as Map<String, dynamic>?;
      if (pagination != null) {
        currentPage = pagination['current_page'] as int? ?? 1;
        lastPage = pagination['last_page'] as int? ?? 1;
        perPage = pagination['per_page'] as int? ?? 15;
      } else if (dataField is Map) {
        currentPage = dataField['current_page'] as int? ?? 1;
        lastPage = dataField['last_page'] as int? ?? 1;
        perPage = dataField['per_page'] as int? ?? 15;
      }
    } else if (rawData is List) {
      rawList = rawData;
    }

    return PaginatedResponse<T>(
      items: rawList.map(fromJson).toList(),
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPage,
    );
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
