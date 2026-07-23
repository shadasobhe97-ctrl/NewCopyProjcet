import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/driver/finance/data/models/wallet_model.dart';
import 'package:kids_transport/features/driver/finance/data/models/withdrawal_model.dart';
import 'package:kids_transport/features/driver/finance/data/models/invoice_model.dart';
import 'package:kids_transport/features/driver/finance/data/models/invoice_details_model.dart';
import 'package:kids_transport/features/driver/finance/data/repositories/finance_repository.dart';

part 'finance_state.dart';

class FinanceCubit extends Cubit<FinanceState> {
  final FinanceRepository _repository;

  FinanceCubit(this._repository) : super(FinanceInitial());

  Future<void> loadDashboard() async {
    emit(FinanceLoading());
    try {
      final wallet = await _repository.getWalletBalance();
      final withdrawals = await _repository.getWithdrawals();
      final invoices = await _repository.getInvoices();
      emit(FinanceDashboardLoaded(
        wallet: wallet,
        withdrawals: withdrawals,
        invoices: invoices,
      ));
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }

  Future<void> loadWithdrawals() async {
    emit(FinanceLoading());
    try {
      final withdrawals = await _repository.getWithdrawals();
      emit(FinanceWithdrawalsLoaded(withdrawals: withdrawals));
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }

  Future<void> loadInvoices() async {
    emit(FinanceLoading());
    try {
      final invoices = await _repository.getInvoices();
      emit(FinanceInvoicesLoaded(invoices: invoices));
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }

  Future<void> loadInvoiceDetails(int id) async {
    emit(FinanceLoading());
    try {
      final details = await _repository.getInvoiceDetails(id);
      emit(FinanceInvoiceDetailsLoaded(details: details));
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }

  Future<bool> createWithdrawal(Map<String, dynamic> body) async {
    emit(FinanceSubmitting());
    try {
      await _repository.createWithdrawal(body);
      return true;
    } catch (e) {
      emit(FinanceError(e.toString()));
      return false;
    }
  }
}
