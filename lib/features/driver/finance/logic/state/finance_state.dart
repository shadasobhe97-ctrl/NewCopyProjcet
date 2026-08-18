import '../../data/models/wallet_model.dart';
import '../../data/models/withdrawal_model.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/invoice_details_model.dart';

abstract class FinanceState {}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceSubmitting extends FinanceState {}

class FinanceDashboardLoaded extends FinanceState {
  final WalletModel wallet;
  final List<WithdrawalModel> withdrawals;
  final List<InvoiceModel> invoices;

  FinanceDashboardLoaded({
    required this.wallet,
    required this.withdrawals,
    required this.invoices,
  });
}

class FinanceWithdrawalsLoaded extends FinanceState {
  final List<WithdrawalModel> withdrawals;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;
  final String? activeFilter;

  FinanceWithdrawalsLoaded({
    required this.withdrawals,
    required this.currentPage,
    required this.lastPage,
    this.isLoadingMore = false,
    this.activeFilter,
  });

  bool get hasMore => currentPage < lastPage;
}

class FinanceInvoicesLoaded extends FinanceState {
  final List<InvoiceModel> invoices;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;
  final String? activeFilter;

  FinanceInvoicesLoaded({
    required this.invoices,
    required this.currentPage,
    required this.lastPage,
    this.isLoadingMore = false,
    this.activeFilter,
  });

  bool get hasMore => currentPage < lastPage;
}

class FinanceInvoiceDetailsLoaded extends FinanceState {
  final InvoiceDetailsModel details;

  FinanceInvoiceDetailsLoaded({required this.details});
}

class FinanceSuccess extends FinanceState {
  final String message;
  final WithdrawalModel? withdrawal;

  FinanceSuccess(this.message, {this.withdrawal});
}

class FinanceError extends FinanceState {
  final String message;
  FinanceError(this.message);
}
