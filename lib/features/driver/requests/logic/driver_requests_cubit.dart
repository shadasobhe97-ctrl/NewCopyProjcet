import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/driver/requests/data/models/driver_request_model.dart';
import 'package:kids_transport/features/driver/requests/data/repositories/driver_requests_repository.dart';

part 'driver_requests_state.dart';

/// فلاتر الطلبات المتاحة
enum DriverRequestsFilter { all, pending, cancelled, rejected }

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

      final requests = await _repository.getRequests(filter: filterStr);
      emit(DriverRequestsLoaded(requests: requests, activeFilter: filter));
    } catch (e) {
      emit(DriverRequestsError('فشل تحميل الطلبات: ${e.toString()}'));
    }
  }

  /// إعادة التحميل بنفس الفلتر الحالي
  Future<void> refresh() => loadRequests(filter: _currentFilter);

  /// قبول طلب اشتراك
  Future<bool> acceptRequest(int requestId) async {
    try {
      await _repository.acceptRequest(requestId);
      await refresh();
      return true;
    } catch (e) {
      emit(DriverRequestsError('فشل قبول الطلب: ${e.toString()}'));
      return false;
    }
  }

  /// رفض طلب اشتراك
  Future<bool> rejectRequest(int requestId, {String? reason}) async {
    try {
      await _repository.rejectRequest(requestId, reason: reason);
      await refresh();
      return true;
    } catch (e) {
      emit(DriverRequestsError('فشل رفض الطلب: ${e.toString()}'));
      return false;
    }
  }
}
