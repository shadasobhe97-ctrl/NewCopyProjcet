import 'package:kids_transport/features/driver/finance/data/datasources/finance_remote_data_source.dart';
import 'package:kids_transport/features/driver/finance/data/models/wallet_model.dart';
import 'package:kids_transport/features/driver/finance/data/models/withdrawal_model.dart';
import 'package:kids_transport/features/driver/finance/data/models/invoice_model.dart';
import 'package:kids_transport/features/driver/finance/data/models/invoice_details_model.dart';

class FinanceRepository {
  final FinanceRemoteDataSource _remoteDataSource;

  FinanceRepository(this._remoteDataSource);

  Future<WalletModel> getWalletBalance() =>
      _remoteDataSource.getWalletBalance();

  Future<List<WithdrawalModel>> getWithdrawals() =>
      _remoteDataSource.getWithdrawals();

  Future<void> createWithdrawal(Map<String, dynamic> body) async {
    await _remoteDataSource.createWithdrawal(body);
  }

  Future<List<InvoiceModel>> getInvoices() =>
      _remoteDataSource.getInvoices();

  Future<InvoiceDetailsModel> getInvoiceDetails(int id) =>
      _remoteDataSource.getInvoiceDetails(id);
}
