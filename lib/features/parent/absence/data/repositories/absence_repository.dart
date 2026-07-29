import '../datasources/absence_remote_data_source.dart';
import '../models/absence_model.dart';
import '../models/available_absence_dates_model.dart';

class AbsenceRepository {
  final AbsenceRemoteDataSource _remoteDataSource;

  AbsenceRepository(this._remoteDataSource);

  Future<AvailableAbsenceDatesModel> getAvailableAbsenceDates(
    int childId,
  ) async {
    return await _remoteDataSource.getAvailableAbsenceDates(childId);
  }

  Future<List<AbsenceModel>> getAbsences(int childId) async {
    return await _remoteDataSource.getAbsences(childId);
  }

  Future<String?> setAbsence({
    required int childId,
    required List<String> dates,
    required AbsenceType absenceType,
  }) async {
    return await _remoteDataSource.setAbsence(
      childId: childId,
      dates: dates,
      absenceType: absenceType,
    );
  }

  Future<String?> cancelAbsence({
    required int childId,
    required String date,
    required AbsenceType absenceType,
  }) async {
    return await _remoteDataSource.cancelAbsence(
      childId: childId,
      date: date,
      absenceType: absenceType,
    );
  }
}
