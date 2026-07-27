import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/absence_model.dart';
import '../models/available_absence_dates_model.dart';

class AbsenceRemoteDataSource {
  final ApiClient _client;

  AbsenceRemoteDataSource(this._client);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  /// GET /api/parent/children/{childId}/available-absence-dates
  Future<AvailableAbsenceDatesModel> getAvailableAbsenceDates(
    int childId,
  ) async {
    final response = await _client.get(
      ApiEndpoints.childAvailableAbsenceDates(childId),
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر جلب الأيام المتاحة');
      }
      final payload = data['data'] is Map
          ? Map<String, dynamic>.from(data['data'] as Map)
          : Map<String, dynamic>.from(data);
      return AvailableAbsenceDatesModel.fromJson(payload);
    }
    return const AvailableAbsenceDatesModel(
      availableDates: [],
      alreadyAbsentDates: [],
    );
  }

  /// GET /api/parent/children/{childId}/absences
  Future<List<AbsenceModel>> getAbsences(int childId) async {
    final response = await _client.get(
      ApiEndpoints.childAbsences(childId),
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر جلب قائمة الغيابات');
      }
      final rawList =
          data['data'] as List<dynamic>? ??
          data['absences'] as List<dynamic>? ??
          [];
      return rawList
          .map(
            (e) => AbsenceModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } else if (data is List) {
      return data
          .map(
            (e) => AbsenceModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    }
    return [];
  }

  /// POST /api/parent/children/{childId}/set-absence
  /// Body: { "dates": [...], "absence_type": "both" }
  Future<void> setAbsence({
    required int childId,
    required List<String> dates,
    required AbsenceType absenceType,
  }) async {
    final body = <String, dynamic>{
      'dates': dates,
      'absence_type': absenceType.value,
    };

    final response = await _client.post(
      ApiEndpoints.childSetAbsence(childId),
      data: body,
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تسجيل الغياب');
      }
    }
  }

  /// POST /api/parent/children/{childId}/cancel-absence
  /// Body: { "dates": [date], "absence_type": "..." }
  Future<void> cancelAbsence({
    required int childId,
    required String date,
    required AbsenceType absenceType,
  }) async {
    final body = <String, dynamic>{
      'dates': [date],
      'absence_type': absenceType.value,
    };

    final response = await _client.post(
      ApiEndpoints.childCancelAbsence(childId),
      data: body,
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر إلغاء الغياب');
      }
    }
  }
}
