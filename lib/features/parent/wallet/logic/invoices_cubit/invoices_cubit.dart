import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/parent/wallet/data/repositories/invoices_repository.dart';
import 'package:kids_transport/features/parent/wallet/logic/invoices_cubit/invoices_state.dart';
import 'package:dio/dio.dart';

class InvoicesCubit extends Cubit<InvoicesState> {
  final InvoicesRepository _repository;

  InvoicesCubit(this._repository) : super(InvoicesInitial());

  Future<void> loadInvoices() async {
    emit(InvoicesLoading());
    try {
      final invoices = await _repository.getInvoices();
      emit(InvoicesLoaded(invoices));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'فشل في تحميل الفواتير';
      emit(InvoicesError(msg.toString()));
    } catch (e) {
      emit(InvoicesError(e.toString()));
    }
  }
}
