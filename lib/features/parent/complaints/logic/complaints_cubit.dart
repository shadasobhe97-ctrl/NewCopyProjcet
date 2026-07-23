import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/complaints_repository.dart';
import '../data/models/complaint_model.dart';
import 'complaints_state.dart';

class ComplaintsCubit extends Cubit<ComplaintsState> {
  final ComplaintsRepository _repository;

  ComplaintsCubit(this._repository) : super(ComplaintsInitial());

  /// Load complaints list with optional type filter ('all', 'pending', 'action_taken')
  Future<void> fetchComplaints({String type = 'all'}) async {
    emit(ComplaintsLoading());
    try {
      final complaints = await _repository.getComplaints(type: type);
      emit(ComplaintsLoaded(complaints: complaints, activeType: type));
    } catch (e) {
      emit(ComplaintsError(_parseError(e)));
    }
  }

  /// Load details for a single complaint
  Future<void> fetchComplaintDetails(int id) async {
    emit(ComplaintDetailsLoading());
    try {
      final complaint = await _repository.getComplaintDetails(id);
      emit(ComplaintDetailsLoaded(complaint));
    } catch (e) {
      emit(ComplaintsError(_parseError(e)));
    }
  }

  /// Fetch driver trips for the trip selector dropdown
  Future<void> fetchDriverTrips(int driverId) async {
    emit(DriverTripsLoading());
    try {
      final trips = await _repository.getDriverTrips(driverId);
      emit(DriverTripsLoaded(trips));
    } catch (e) {
      emit(ComplaintsError(_parseError(e)));
    }
  }

  /// Submit a new complaint
  Future<void> createComplaint({
    required int driverId,
    required int tripId,
    required String description,
  }) async {
    final currentState = state;
    List<ComplaintModel> currentList = [];
    if (currentState is ComplaintsLoaded) {
      currentList = currentState.complaints;
    }

    emit(ComplaintSubmitting(currentComplaints: currentList));
    try {
      final created = await _repository.createComplaint(
        driverId: driverId,
        tripId: tripId,
        description: description,
      );
      emit(ComplaintSuccess('تم إرسال الشكوى بنجاح، وستقوم الإدارة بمراجعتها.', complaint: created));
    } catch (e) {
      emit(ComplaintsError(_parseError(e)));
      if (currentList.isNotEmpty) {
        emit(ComplaintsLoaded(complaints: currentList));
      }
    }
  }

  /// Update an existing pending complaint
  Future<void> updateComplaint({
    required int id,
    required String description,
    int? tripId,
  }) async {
    final currentState = state;
    List<ComplaintModel> currentList = [];
    if (currentState is ComplaintsLoaded) {
      currentList = currentState.complaints;
    }

    emit(ComplaintSubmitting(currentComplaints: currentList));
    try {
      final updated = await _repository.updateComplaint(
        id: id,
        description: description,
        tripId: tripId,
      );
      emit(ComplaintSuccess('تم تعديل الشكوى بنجاح', complaint: updated));
    } catch (e) {
      emit(ComplaintsError(_parseError(e)));
      if (currentList.isNotEmpty) {
        emit(ComplaintsLoaded(complaints: currentList));
      }
    }
  }

  /// Delete a pending complaint
  Future<void> deleteComplaint(int id) async {
    final currentState = state;
    List<ComplaintModel> currentList = [];
    if (currentState is ComplaintsLoaded) {
      currentList = currentState.complaints;
    }

    emit(ComplaintSubmitting(currentComplaints: currentList));
    try {
      await _repository.deleteComplaint(id);
      emit(const ComplaintSuccess('تم حذف الشكوى بنجاح'));
    } catch (e) {
      emit(ComplaintsError(_parseError(e)));
      if (currentList.isNotEmpty) {
        emit(ComplaintsLoaded(complaints: currentList));
      }
    }
  }

  String _parseError(dynamic e) {
    if (e is DioException) {
      if (e.response != null) {
        final code = e.response!.statusCode;
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }
        switch (code) {
          case 401:
            return 'غير مصرح لك بالوصول. يرجى تسجيل الدخول مجدداً.';
          case 403:
            return 'ليس لديك صلاحية لإجراء هذه العملية.';
          case 404:
            return 'لم يتم العثور على المورد المطلوب.';
          case 422:
            return 'البيانات المرسلة غير صالحة. يرجى التأكد من الحقول.';
          case 500:
            return 'حدث خطأ في الخادم الداخلي. يرجى المحاولة لاحقاً.';
          default:
            return 'خطأ في الاتصال بالخادم ($code)';
        }
      }
      return 'فشل الاتصال بالإنترنت. يرجى التحقق من الشبكة.';
    }
    return e.toString().replaceAll('Exception:', '');
  }
}
