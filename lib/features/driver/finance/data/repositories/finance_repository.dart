import '../datasources/finance_remote_data_source.dart';
import '../models/paginated_response.dart';
import '../models/wallet_model.dart';
import '../models/withdrawal_model.dart';
import '../models/invoice_model.dart';
import '../models/invoice_details_model.dart';

class FinanceRepository {
  final FinanceRemoteDataSource _remoteDataSource;

  FinanceRepository(this._remoteDataSource);

  Future<WalletModel> getWalletBalance() =>
      _remoteDataSource.getWalletBalance();

  Future<PaginatedResponse<WithdrawalModel>> getWithdrawals({
    String? status,
    int page = 1,
  }) =>
      _remoteDataSource.getWithdrawals(status: status, page: page);

  Future<WithdrawalModel> createWithdrawal(Map<String, dynamic> body) =>
      _remoteDataSource.createWithdrawal(body);

  Future<PaginatedResponse<InvoiceModel>> getInvoices({
    String? status,
    int page = 1,
  }) =>
      _remoteDataSource.getInvoices(status: status, page: page);

  Future<InvoiceDetailsModel> getInvoiceDetails(int id) =>
      _remoteDataSource.getInvoiceDetails(id);
}
