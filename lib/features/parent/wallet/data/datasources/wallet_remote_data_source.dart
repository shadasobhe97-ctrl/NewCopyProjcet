import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/features/parent/wallet/data/models/payment_method_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/recharge_response_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/wallet_balance_model.dart';

class WalletRemoteDataSource {
  final ApiClient _apiClient;

  WalletRemoteDataSource(this._apiClient);

  Future<WalletBalanceModel> getBalance() async {
    final response = await _apiClient.get(ApiEndpoints.parentWalletBalance);
    return WalletBalanceModel.fromJson(response.data['data']);
  }

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final response = await _apiClient.get(ApiEndpoints.parentWalletPaymentMethods);
    final data = response.data['data'] as List;
    return data.map((e) => PaymentMethodModel.fromJson(e)).toList();
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
    );
    return RechargeResponseModel.fromJson(response.data['data']);
  }
}
