import 'package:kids_transport/features/parent/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:kids_transport/features/parent/wallet/data/models/payment_method_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/recharge_response_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/wallet_balance_model.dart';

class WalletRepository {
  final WalletRemoteDataSource _remoteDataSource;

  WalletRepository(this._remoteDataSource);

  Future<WalletBalanceModel> getBalance() async {
    return await _remoteDataSource.getBalance();
  }

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    return await _remoteDataSource.getPaymentMethods();
  }

  Future<RechargeResponseModel> rechargeWallet({
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
  }) async {
    return await _remoteDataSource.rechargeWallet(
      amount: amount,
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
    );
  }
}
