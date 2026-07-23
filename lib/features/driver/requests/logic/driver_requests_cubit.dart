import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/driver/requests/data/models/driver_request_model.dart';
import 'package:kids_transport/features/driver/requests/data/repositories/driver_requests_repository.dart';

part 'driver_requests_state.dart';

/// فلاتر الطلبات المتاحة
enum DriverRequestsFilter { all, pending, accepted, cancelled, rejected }

/// كوبيت إدارة طلبات الاشتراك للسائق
class DriverRequestsCubit extends Cubit<DriverRequestsState> {
  final DriverRequestsRepository _repository;

  DriverRequestsCubit(this._repository) : super(DriverRequestsInitial());

  DriverRequestsFilter _currentFilter = DriverRequestsFilter.all;
  DriverRequestsFilter get currentFilter => _currentFilter;

  /// تحميل الطلبات حسب الفلتر
  Future<void> loadRequests({
    DriverRequestsFilter filter = DriverRequestsFilter.all,
  }) async {
    _currentFilter = filter;
    emit(DriverRequestsLoading());

    try {
      final String? filterStr;
      switch (filter) {
        case DriverRequestsFilter.pending:
          filterStr = 'pending';
          break;
        case DriverRequestsFilter.accepted:
          filterStr = 'accepted';
          break;
        case DriverRequestsFilter.cancelled:
          filterStr = 'cancelled';
          break;
        case DriverRequestsFilter.rejected:
          filterStr = 'rejected';
          break;
        case DriverRequestsFilter.all:
          filterStr = null;
          break;
      }

      final response = await _repository.getRequests(filter: filterStr, page: 1);
      emit(DriverRequestsLoaded(
        requests: response.data,
        activeFilter: filter,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        hasMore: response.hasMore,
      ));
    } catch (e) {
      emit(DriverRequestsError('فشل تحميل الطلبات: ${e.toString()}'));
    }
  }

  /// تحميل المزيد من الطلبات (Pagination)
  Future<void> loadMoreRequests() async {
    final currentState = state;
    if (currentState is DriverRequestsLoaded) {
      if (!currentState.hasMore || currentState.isLoadingMore) return;

      emit(currentState.copyWith(isLoadingMore: true));

      try {
        final String? filterStr;
        switch (currentState.activeFilter) {
          case DriverRequestsFilter.pending:
            filterStr = 'pending';
            break;
          case DriverRequestsFilter.accepted:
            filterStr = 'accepted';
            break;
          case DriverRequestsFilter.cancelled:
            filterStr = 'cancelled';
            break;
          case DriverRequestsFilter.rejected:
            filterStr = 'rejected';
            break;
          case DriverRequestsFilter.all:
            filterStr = null;
            break;
        }

        final nextPage = currentState.currentPage + 1;
        final response = await _repository.getRequests(filter: filterStr, page: nextPage);

        emit(currentState.copyWith(
          requests: List.of(currentState.requests)..addAll(response.data),
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          hasMore: response.hasMore,
          isLoadingMore: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
        // You might want to handle error without completely overriding the loaded state,
        // or just let the user try again.
      }
    }
  }

  /// تحميل طلب فردي من API التفاصيل
  Future<void> loadRequestDetails(int requestId) async {
    emit(DriverRequestDetailsLoading());
    try {
      final request = await _repository.getRequestDetails(requestId);
      emit(DriverRequestDetailsLoaded(request));
    } catch (e) {
      emit(DriverRequestDetailsError('فشل تحميل تفاصيل الطلب: ${e.toString()}'));
    }
  }

  /// إعادة التحميل بنفس الفلتر الحالي
  Future<void> refresh() => loadRequests(filter: _currentFilter);

  /// قبول طلب اشتراك
  Future<bool> acceptRequest(int requestId) async {
    try {
      await _repository.acceptRequest(requestId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// رفض طلب اشتراك
  Future<bool> rejectRequest(int requestId, {required String reason}) async {
    try {
      await _repository.rejectRequest(requestId, reason: reason);
      return true;
    } catch (e) {
      return false;
    }
  }
}
