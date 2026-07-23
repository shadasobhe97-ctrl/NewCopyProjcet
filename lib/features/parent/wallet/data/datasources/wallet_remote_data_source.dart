import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/parent/wallet/data/models/payment_method_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/recharge_response_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/wallet_balance_model.dart';

class WalletRemoteDataSource {
  final ApiClient _apiClient;

  WalletRemoteDataSource(this._apiClient);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  Future<WalletBalanceModel> getBalance() async {
    final response = await _apiClient.get(
      ApiEndpoints.parentWalletBalance,
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل رصيد المحفظة.');
      }
    }
    return WalletBalanceModel.fromJson(data['data']);
  }

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final response = await _apiClient.get(
      ApiEndpoints.parentWalletPaymentMethods,
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل طرق الدفع.');
      }
    }
    final list = data['data'] as List;
    return list.map((e) => PaymentMethodModel.fromJson(e)).toList();
  }

  Future<RechargeResponseModel> rechargeWallet({
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.parentWalletRecharge,
      data: {
        'amount': amount,
        'payment_method': paymentMethod,
        'reference_number': referenceNumber,
      },
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر إجراء عملية الشحن.');
      }
    }
    return RechargeResponseModel.fromJson(data['data']);
  }
}
