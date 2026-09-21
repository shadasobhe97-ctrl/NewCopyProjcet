import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../parent/location_change/data/models/location_change_request_model.dart';
import '../repositories/driver_location_change_repository.dart';

abstract class DriverLocationChangeState {}

class DriverLocationChangeInitial extends DriverLocationChangeState {}

class DriverLocationChangeLoading extends DriverLocationChangeState {}

class DriverLocationChangeLoaded extends DriverLocationChangeState {
  final List<LocationChangeRequestModel> requests;
  final String currentFilter;
  final int pendingCount;

  DriverLocationChangeLoaded({
    required this.requests,
    required this.currentFilter,
    required this.pendingCount,
  });
}

class DriverLocationChangeActionLoading extends DriverLocationChangeState {
  final int requestId;
  DriverLocationChangeActionLoading(this.requestId);
}

class DriverLocationChangeActionSuccess extends DriverLocationChangeState {
  final String message;
  DriverLocationChangeActionSuccess(this.message);
}

class DriverLocationChangeError extends DriverLocationChangeState {
  final String message;
  DriverLocationChangeError(this.message);
}

class DriverLocationChangeCubit extends Cubit<DriverLocationChangeState> {
  final DriverLocationChangeRepository _repository;

  DriverLocationChangeCubit(this._repository)
      : super(DriverLocationChangeInitial());

  int _pendingCount = 0;
  int get pendingCount => _pendingCount;

  /// جلب عدد الطلبات المعلقة لسريعا (من أجل Badge العداد في الصفحة الرئيسية)
  Future<int> fetchPendingCount() async {
    try {
      final pendingRequests = await _repository.getRequests(status: 'pending');
      _pendingCount = pendingRequests.length;
      return _pendingCount;
    } catch (_) {
      return _pendingCount;
    }
  }

  /// تحميل قائمة طلبات تغيير الموقع بالسائق حسب الفلتر
  Future<void> loadRequests({String filter = 'pending'}) async {
    emit(DriverLocationChangeLoading());
    try {
      // 1. جلب الطلبات المعلقة أولاً لتحديث العداد بدقة
      final pendingList = await _repository.getRequests(status: 'pending');
      _pendingCount = pendingList.length;

      // 2. جلب الطلبات حسب الفلتر المختار
      List<LocationChangeRequestModel> requests;
      if (filter == 'pending') {
        requests = pendingList;
      } else {
        requests = await _repository.getRequests(status: filter);
      }

      emit(DriverLocationChangeLoaded(
        requests: requests,
        currentFilter: filter,
        pendingCount: _pendingCount,
      ));
    } catch (e) {
      emit(DriverLocationChangeError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// الرد على الطلب (موافقة أو رفض)
  Future<void> respondToRequest(
    int id, {
    required String status,
    String? rejectionReason,
    String currentFilter = 'pending',
  }) async {
    emit(DriverLocationChangeActionLoading(id));
    try {
      final res = await _repository.respondToRequest(
        id,
        status: status,
        rejectionReason: rejectionReason,
      );

      final message = res['message']?.toString() ??
          (status == 'approved' ? 'تمت الموافقة بنجاح' : 'تم الرفض بنجاح');

      emit(DriverLocationChangeActionSuccess(message));

      // إعادة تحميل القائمة والعداد بعد تنفيذ الإجراء
      await loadRequests(filter: currentFilter);
    } catch (e) {
      emit(DriverLocationChangeError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
