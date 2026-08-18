import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/finance_repository.dart';
import '../state/finance_state.dart';

class FinanceCubit extends Cubit<FinanceState> {
  final FinanceRepository _repository;

  FinanceCubit(this._repository) : super(FinanceInitial());

  Future<void> loadDashboard() async {
    emit(FinanceLoading());
    try {
      final wallet = await _repository.getWalletBalance();
      final withdrawals = await _repository.getWithdrawals(page: 1);
      final invoices = await _repository.getInvoices(page: 1);
      emit(FinanceDashboardLoaded(
        wallet: wallet,
        withdrawals: withdrawals.items,
        invoices: invoices.items,
      ));
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }

  Future<void> loadWithdrawals({String? status}) async {
    emit(FinanceLoading());
    try {
      final result = await _repository.getWithdrawals(status: status, page: 1);
      emit(FinanceWithdrawalsLoaded(
        withdrawals: result.items,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        activeFilter: status,
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
      activeFilter: current.activeFilter,
      isLoadingMore: true,
    ));

    try {
      final result = await _repository.getWithdrawals(
        status: current.activeFilter,
        page: current.currentPage + 1,
      );
      emit(FinanceWithdrawalsLoaded(
        withdrawals: [...current.withdrawals, ...result.items],
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        activeFilter: current.activeFilter,
      ));
    } catch (e) {
      emit(FinanceWithdrawalsLoaded(
        withdrawals: current.withdrawals,
        currentPage: current.currentPage,
        lastPage: current.lastPage,
        activeFilter: current.activeFilter,
      ));
    }
  }

  Future<void> loadInvoices({String? status}) async {
    emit(FinanceLoading());
    try {
      final result = await _repository.getInvoices(status: status, page: 1);
      emit(FinanceInvoicesLoaded(
        invoices: result.items,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        activeFilter: status,
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
      activeFilter: current.activeFilter,
      isLoadingMore: true,
    ));

    try {
      final result = await _repository.getInvoices(
        status: current.activeFilter,
        page: current.currentPage + 1,
      );
      emit(FinanceInvoicesLoaded(
        invoices: [...current.invoices, ...result.items],
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        activeFilter: current.activeFilter,
      ));
    } catch (e) {
      emit(FinanceInvoicesLoaded(
        invoices: current.invoices,
        currentPage: current.currentPage,
        lastPage: current.lastPage,
        activeFilter: current.activeFilter,
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
      final createdWithdrawal = await _repository.createWithdrawal(body);
      emit(FinanceSuccess(
        "تم تقديم طلب السحب بنجاح. بانتظار مراجعة الإدارة.",
        withdrawal: createdWithdrawal,
      ));
      return true;
    } catch (e) {
      emit(FinanceError(e.toString()));
      return false;
    }
  }
}
