import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/parent/wallet/data/repositories/invoices_repository.dart';
import 'package:kids_transport/features/parent/wallet/logic/invoice_details_cubit/invoice_details_state.dart';
import 'package:dio/dio.dart';

class InvoiceDetailsCubit extends Cubit<InvoiceDetailsState> {
  final InvoicesRepository _repository;

  InvoiceDetailsCubit(this._repository) : super(InvoiceDetailsInitial());

  Future<void> loadInvoiceDetails(int id) async {
    emit(InvoiceDetailsLoading());
    try {
      final invoice = await _repository.getInvoiceDetails(id);
      emit(InvoiceDetailsLoaded(invoice));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'فشل في تحميل تفاصيل الفاتورة';
      emit(InvoiceDetailsError(msg.toString()));
    } catch (e) {
      emit(InvoiceDetailsError(e.toString()));
    }
  }
}
