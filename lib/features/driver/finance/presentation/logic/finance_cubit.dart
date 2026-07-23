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
      final withdrawals = await _repository.getWithdrawals(1);
      final invoices = await _repository.getInvoices(1);
      emit(FinanceDashboardLoaded(
        wallet: wallet,
        withdrawals: withdrawals.items,
        invoices: invoices.items,
      ));
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }

  Future<void> loadWithdrawals() async {
    emit(FinanceLoading());
    try {
      final result = await _repository.getWithdrawals(1);
      emit(FinanceWithdrawalsLoaded(
        withdrawals: result.items,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
      ));
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }

  Future<void> loadMoreWithdrawals() async {
    final current = state;
    if (current is! FinanceWithdrawalsLoaded || !current.hasMore || current.isLoadingMore) return;

    emit(FinanceWithdrawalsLoaded(
      withdrawals: current.withdrawals,
      currentPage: current.currentPage,
      lastPage: current.lastPage,
      isLoadingMore: true,
    ));

    try {
      final result = await _repository.getWithdrawals(current.currentPage + 1);
      emit(FinanceWithdrawalsLoaded(
        withdrawals: [...current.withdrawals, ...result.items],
        currentPage: result.currentPage,
        lastPage: result.lastPage,
      ));
    } catch (e) {
      emit(FinanceWithdrawalsLoaded(
        withdrawals: current.withdrawals,
        currentPage: current.currentPage,
        lastPage: current.lastPage,
      ));
    }
  }

  Future<void> loadInvoices() async {
    emit(FinanceLoading());
    try {
      final result = await _repository.getInvoices(1);
      emit(FinanceInvoicesLoaded(
        invoices: result.items,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
      ));
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }

  Future<void> loadMoreInvoices() async {
    final current = state;
    if (current is! FinanceInvoicesLoaded || !current.hasMore || current.isLoadingMore) return;

    emit(FinanceInvoicesLoaded(
      invoices: current.invoices,
      currentPage: current.currentPage,
      lastPage: current.lastPage,
      isLoadingMore: true,
    ));

    try {
      final result = await _repository.getInvoices(current.currentPage + 1);
      emit(FinanceInvoicesLoaded(
        invoices: [...current.invoices, ...result.items],
        currentPage: result.currentPage,
        lastPage: result.lastPage,
      ));
    } catch (e) {
      emit(FinanceInvoicesLoaded(
        invoices: current.invoices,
        currentPage: current.currentPage,
        lastPage: current.lastPage,
      ));
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
