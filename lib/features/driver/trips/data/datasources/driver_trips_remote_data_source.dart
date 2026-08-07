import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_details_model.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_history_model.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_live_model.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_model.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_stop_model.dart';
import 'package:kids_transport/features/driver/trips/data/models/trip_action_result_model.dart';

/// مصدر بيانات الرحلات الخاص بالسائق — مرتبط 100% بالـ Backend الحقيقي
class DriverTripsRemoteDataSource {
  final ApiClient _apiClient;

  DriverTripsRemoteDataSource(this._apiClient);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  /// يتحقق من غلاف الاستجابة {"status": "success"|"error", ...} ويرمي استثناء عند الفشل
  Map<String, dynamic> _unwrap(dynamic raw, String fallbackMessage) {
    if (raw is! Map) {
      throw ApiException(fallbackMessage);
    }
    final map = Map<String, dynamic>.from(raw);
    if (map['status'] == 'error') {
      final msg = ApiException.extractMessage(map) ?? fallbackMessage;
      throw ApiException(msg, errorCode: map['error_code']?.toString());
    }
    return map;
  }

  Future<List<DriverTripModel>> fetchTripsToday() async {
    final response = await _apiClient.get(
      ApiEndpoints.driverTripsToday,
      headers: _authHeader,
    );
    final map = _unwrap(response.data, 'تعذر تحميل رحلات اليوم.');
    final rawList = map['data'];
    if (rawList is! List) return const [];
    return rawList
        .whereType<Map>()
        .map((e) => DriverTripModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<DriverTripDetailsModel> fetchTripDetails(int tripId) async {
    final response = await _apiClient.get(
      ApiEndpoints.driverTripDetails(tripId),
      headers: _authHeader,
    );
    final map = _unwrap(response.data, 'تعذر تحميل تفاصيل الرحلة.');
    final data = map['data'];
    if (data is Map) {
      return DriverTripDetailsModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw const ApiException('تعذر تحميل تفاصيل الرحلة.');
  }

  Future<TripStartResultModel> startTrip(
    int tripId, {
    double? latitude,
    double? longitude,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverTripStart(tripId),
      data: {
        'latitude': ?latitude,
        'longitude': ?longitude,
      },
      headers: _authHeader,
    );
    final map = _unwrap(response.data, 'تعذر بدء الرحلة.');
    final data = map['data'];
    if (data is Map) {
      return TripStartResultModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw const ApiException('تعذر بدء الرحلة.');
  }

  Future<DriverTripLiveModel> fetchTripLive(int tripId) async {
    final response = await _apiClient.get(
      ApiEndpoints.driverTripLive(tripId),
      headers: _authHeader,
    );
    final map = _unwrap(response.data, 'تعذر تحميل بيانات الرحلة الحية.');
    final data = map['data'];
    if (data is Map) {
      return DriverTripLiveModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw const ApiException('تعذر تحميل بيانات الرحلة الحية.');
  }

  Future<void> updateLocation(
    int tripId, {
    required double latitude,
    required double longitude,
    double? speed,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverTripLocation(tripId),
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'speed': ?speed,
      },
      headers: _authHeader,
    );
    _unwrap(response.data, 'تعذر تحديث الموقع.');
  }

  Future<DriverTripStopsResponseModel> fetchStops(int tripId) async {
    final response = await _apiClient.get(
      ApiEndpoints.driverTripStops(tripId),
      headers: _authHeader,
    );
    final map = _unwrap(response.data, 'تعذر تحميل محطات الرحلة.');
    final data = map['data'];
    if (data is Map) {
      return DriverTripStopsResponseModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw const ApiException('تعذر تحميل محطات الرحلة.');
  }

  Future<ChildStatusActionResultModel> updateChildStatus(
    int tripId,
    int tripChildId, {
    required String action,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverTripChildStatus(tripId, tripChildId),
      data: {
        'action': action,
        'latitude': ?latitude,
        'longitude': ?longitude,
      },
      headers: _authHeader,
    );
    final map = _unwrap(response.data, 'تعذر تحديث حالة الطفل.');
    return ChildStatusActionResultModel.fromJson(map);
  }

  Future<ChildStatusActionResultModel> skipChild(int tripId, int tripChildId) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverTripSkipChild(tripId, tripChildId),
      data: const {'action': 'skip'},
      headers: _authHeader,
    );
    final map = _unwrap(response.data, 'تعذر تجاوز المحطة.');
    return ChildStatusActionResultModel.fromJson(map);
  }

  Future<ChildStatusActionResultModel> verifyQr(
    int tripId,
    int tripChildId, {
    required String qrCodeToken,
    String? stage,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverTripVerifyQr(tripId, tripChildId),
      data: {
        'qr_code_token': qrCodeToken,
        'stage': ?stage,
      },
      headers: _authHeader,
    );
    final map = _unwrap(response.data, 'تعذر التحقق من رمز QR.');
    return ChildStatusActionResultModel.fromJson(map);
  }

  Future<TripCompleteSummaryModel> completeTrip(int tripId) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverTripComplete(tripId),
      headers: _authHeader,
    );
    final map = _unwrap(response.data, 'تعذر إنهاء الرحلة.');
    final summary = map['summary'];
    if (summary is Map) {
      return TripCompleteSummaryModel.fromJson(Map<String, dynamic>.from(summary));
    }
    throw const ApiException('تعذر إنهاء الرحلة.');
  }

  Future<List<DriverTripHistoryModel>> fetchHistory() async {
    final response = await _apiClient.get(
      ApiEndpoints.driverTripsHistory,
      headers: _authHeader,
    );
    final map = _unwrap(response.data, 'تعذر تحميل سجل الرحلات.');
    final rawList = map['data'];
    if (rawList is! List) return const [];
    return rawList
        .whereType<Map>()
        .map((e) => DriverTripHistoryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<DriverTripHistoryDetailsModel> fetchHistoryDetails(int tripId) async {
    final response = await _apiClient.get(
      ApiEndpoints.driverTripHistoryDetails(tripId),
      headers: _authHeader,
    );
    final map = _unwrap(response.data, 'تعذر تحميل تفاصيل الرحلة.');
    final data = map['data'];
    if (data is Map) {
      return DriverTripHistoryDetailsModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw const ApiException('تعذر تحميل تفاصيل الرحلة.');
  }

  Future<void> registerAbsence(List<String> dates) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverTripsRegisterAbsence,
      data: {'dates': dates},
      headers: _authHeader,
    );
    _unwrap(response.data, 'تعذر تسجيل الغياب.');
  }

  Future<TripStatusChangeResultModel> reportBreakdown(int tripId, {String? reason}) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverTripReportBreakdown(tripId),
      data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
      headers: _authHeader,
    );
    final map = _unwrap(response.data, 'تعذر تسجيل توقف الرحلة.');
    final data = map['data'];
    if (data is Map) {
      return TripStatusChangeResultModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw const ApiException('تعذر تسجيل توقف الرحلة.');
  }

  Future<TripStatusChangeResultModel> resumeTrip(int tripId) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverTripResume(tripId),
      headers: _authHeader,
    );
    final map = _unwrap(response.data, 'تعذر استئناف الرحلة.');
    final data = map['data'];
    if (data is Map) {
      return TripStatusChangeResultModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw const ApiException('تعذر استئناف الرحلة.');
  }
}
