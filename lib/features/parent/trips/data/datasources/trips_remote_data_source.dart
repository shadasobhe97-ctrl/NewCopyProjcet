import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/active_trip_model.dart';
import '../models/trip_track_model.dart';
import '../models/upcoming_trip_model.dart';
import '../models/trip_history_model.dart';
import '../models/trip_details_model.dart';
import '../models/trip_timeline_model.dart';
import '../models/child_trips_model.dart';

class TripsRemoteDataSource {
  final ApiClient _apiClient;

  TripsRemoteDataSource(this._apiClient);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  /// 1. GET /api/parent/trips/active
  Future<List<ActiveTripModel>> getActiveTrips() async {
    final response = await _apiClient.get(
      ApiEndpoints.parentActiveTrips,
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false || success == 'error') {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل الرحلات النشطة.');
      }
    }
    final payload = (data is Map && data['data'] != null) ? data['data'] : data;
    if (payload is List) {
      return payload
          .map((e) => ActiveTripModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return [];
  }

  /// 2. GET /api/parent/trips/{tripId}/track
  Future<LiveTrackingModel> getTripTrack(dynamic tripId) async {
    final response = await _apiClient.get(
      ApiEndpoints.parentTripTrack(tripId),
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false || success == 'error') {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل مسار الرحلة.');
      }
    }
    if (data is Map && data['data'] != null) {
      return LiveTrackingModel.fromJson(
          Map<String, dynamic>.from(data['data'] as Map));
    }
    if (data is Map<String, dynamic>) {
      return LiveTrackingModel.fromJson(data);
    }
    throw ApiException('استجابة غير متوقعة عند جلب مسار الرحلة.');
  }

  /// 3. GET /api/parent/trips/active/tracking (تتبع جميع الرحلات)
  Future<List<LiveTrackingModel>> getMultipleActiveTracking() async {
    final response = await _apiClient.get(
      ApiEndpoints.parentMultipleActiveTracking,
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false || success == 'error') {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل مواقع جميع الرحلات النشطة.');
      }
    }
    final payload = (data is Map && data['data'] != null) ? data['data'] : data;
    if (payload is List) {
      return payload
          .map((e) => LiveTrackingModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return [];
  }

  /// 4. GET /api/parent/trips/upcoming
  Future<List<UpcomingTripModel>> getUpcomingTrips() async {
    final response = await _apiClient.get(
      ApiEndpoints.parentUpcomingTrips,
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false || success == 'error') {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل الرحلات القادمة.');
      }
    }
    final payload = (data is Map && data['data'] != null) ? data['data'] : data;
    if (payload is List) {
      return payload
          .map((e) => UpcomingTripModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return [];
  }

  /// 5. GET /api/parent/trips/history?page=1&per_page=15
  Future<TripHistoryResponseModel> getTripHistory({
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.parentTripHistory,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false || success == 'error') {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل سجل الرحلات.');
      }
    }
    if (data is Map<String, dynamic>) {
      return TripHistoryResponseModel.fromJson(data);
    }
    throw ApiException('استجابة غير متوقعة من السيرفر عند جلب سجل الرحلات.');
  }

  /// 6. GET /api/parent/trips/{tripId}
  Future<TripDetailsModel> getTripDetails(dynamic tripId) async {
    final response = await _apiClient.get(
      ApiEndpoints.parentTripDetails(tripId),
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false || success == 'error') {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل تفاصيل الرحلة.');
      }
    }
    if (data is Map && data['data'] != null) {
      return TripDetailsModel.fromJson(Map<String, dynamic>.from(data['data'] as Map));
    }
    if (data is Map<String, dynamic>) {
      return TripDetailsModel.fromJson(data);
    }
    throw ApiException('استجابة غير متوقعة عند جلب تفاصيل الرحلة.');
  }

  /// 7. GET /api/parent/trips/{tripId}/timeline
  Future<List<TripTimelineItemModel>> getTripTimeline(dynamic tripId) async {
    final response = await _apiClient.get(
      ApiEndpoints.parentTripTimeline(tripId),
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false || success == 'error') {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل الـ Timeline الخاصة بالرحلة.');
      }
    }
    final payload = (data is Map && data['data'] != null) ? data['data'] : data;
    if (payload is List) {
      return payload
          .map((e) => TripTimelineItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return [];
  }

  /// 8. GET /api/parent/children/{childId}/trips
  Future<ChildTripsModel> getChildTrips(dynamic childId) async {
    final response = await _apiClient.get(
      ApiEndpoints.parentChildTrips(childId),
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false || success == 'error') {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل رحلات الطفل.');
      }
    }
    if (data is Map && data['data'] != null) {
      return ChildTripsModel.fromJson(Map<String, dynamic>.from(data['data'] as Map));
    }
    if (data is Map<String, dynamic>) {
      return ChildTripsModel.fromJson(data);
    }
    throw ApiException('استجابة غير متوقعة عند جلب رحلات الطفل.');
  }

  /// 9. GET /api/parent/trips/{tripId}/children/{childId}/status
  Future<Map<String, dynamic>> getChildStatus(dynamic tripId, dynamic childId) async {
    final response = await _apiClient.get(
      ApiEndpoints.parentChildTripStatus(tripId, childId),
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      return data;
    }
    return {};
  }
}
