import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/requests_repository.dart';
import '../../data/models/request_model.dart';
import 'requests_state.dart';

export 'requests_state.dart';

class RequestsCubit extends Cubit<RequestsState> {
  final RequestsRepository _repository;

  RequestsCubit(this._repository) : super(RequestsInitial());

  /// جلب الطلبات من API مع فلتر اختياري
  Future<void> fetchRequests({String? status}) async {
    debugPrint('========== RequestsCubit.fetchRequests(status: $status) ==========');

    emit(RequestsLoading());

    final (requests, error, message) = await _repository.getRequests(status: status);

    if (error != null) {
      debugPrint('RequestsCubit ERROR: $error');
      emit(RequestsError(error));
    } else {
      final list = requests ?? [];
      debugPrint('RequestsCubit SUCCESS: ${list.length} requests, message: $message');
      if (list.isEmpty) {
        emit(RequestsEmpty(message: message));
      } else {
        emit(RequestsLoaded(list, message: message));
      }
    }
  }

  /// جلب تفاصيل طلب واحد
  Future<void> fetchRequestDetail(int id) async {
    emit(RequestDetailLoading());
    final (request, error, message) = await _repository.getRequestDetail(id);
    if (error != null) {
      emit(RequestDetailError(error));
    } else {
      emit(RequestDetailLoaded(request!, message: message));
    }
  }

  /// إلغاء طلب
  Future<void> cancelRequest(int id) async {
    final currentList = state is RequestsLoaded
        ? (state as RequestsLoaded).requests
        : state is RequestsActionSuccess
            ? (state as RequestsActionSuccess).updatedList
            : <RequestModel>[];

    emit(RequestsActionLoading(List.from(currentList), id));

    final (success, message) = await _repository.cancelRequest(id);
    if (success) {
      final updatedList = List<RequestModel>.from(currentList)
        ..removeWhere((r) => r.id == id);
      emit(RequestsActionSuccess(updatedList, message));
    } else {
      emit(RequestsActionError(List.from(currentList), message));
    }
  }
}
