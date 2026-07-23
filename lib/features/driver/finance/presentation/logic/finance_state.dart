part of 'finance_cubit.dart';

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

  FinanceWithdrawalsLoaded({required this.withdrawals});
}

class FinanceInvoicesLoaded extends FinanceState {
  final List<InvoiceModel> invoices;

  FinanceInvoicesLoaded({required this.invoices});
}

class FinanceInvoiceDetailsLoaded extends FinanceState {
  final InvoiceDetailsModel details;

  FinanceInvoiceDetailsLoaded({required this.details});
}

class FinanceSuccess extends FinanceState {
  final String message;
  FinanceSuccess(this.message);
}

class FinanceError extends FinanceState {
  final String message;
  FinanceError(this.message);
}
