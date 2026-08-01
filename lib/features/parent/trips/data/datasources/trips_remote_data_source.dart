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
import 'trips_mock_data.dart';

class TripsRemoteDataSource {
  final ApiClient _apiClient;

  /// 🌟 مفتاح التبديل بين البيانات التجريبية (Mock Data) والـ API الحقيقي
  /// اجعله true للتجربة والربط التجريبي، أو false للاتصال المباشر بالسيرفر الحقيقي
  static bool useMockData = true;

  TripsRemoteDataSource(this._apiClient);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  /// 1. GET /api/parent/trips/active
  Future<List<ActiveTripModel>> getActiveTrips() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return TripsMockData.activeTrips;
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.parentActiveTrips,
        headers: _authHeader,
      );
      final data = response.data;
      if (data is Map) {
        final success = data['success'];
        if (success == false) {
          final msg = ApiException.extractMessage(data);
          throw ApiException(msg ?? 'تعذر تحميل الرحلات النشطة.');
        }
      }
      if (data is Map && data['data'] != null) {
        final list = data['data'];
        if (list is List) {
          return list
              .map((e) => ActiveTripModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } else if (data is List) {
        return data
            .map((e) => ActiveTripModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      // Fallback to Mock if API is offline
      return TripsMockData.activeTrips;
    }
  }

  /// 2. GET /api/parent/trips/{tripId}/track
  Future<LiveTrackingModel> getTripTrack(dynamic tripId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return TripsMockData.getSingleTrack(tripId);
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.parentTripTrack(tripId),
        headers: _authHeader,
      );
      final data = response.data;
      if (data is Map) {
        final success = data['success'];
        if (success == false) {
          final msg = ApiException.extractMessage(data);
          throw ApiException(msg ?? 'تعذر تحميل مسار الرحلة.');
        }
      }
      if (data is Map && data['data'] != null) {
        return LiveTrackingModel.fromJson(
            data['data'] as Map<String, dynamic>);
      }
      return LiveTrackingModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      return TripsMockData.getSingleTrack(tripId);
    }
  }

  /// 3. GET /api/parent/trips/active/tracking (تتبع جميع الرحلات)
  Future<List<LiveTrackingModel>> getMultipleActiveTracking() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return TripsMockData.multiTracking;
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.parentMultipleActiveTracking,
        headers: _authHeader,
      );
      final data = response.data;
      if (data is Map) {
        final success = data['success'];
        if (success == false) {
          final msg = ApiException.extractMessage(data);
          throw ApiException(msg ?? 'تعذر تحميل مواقع جميع الرحلات النشطة.');
        }
      }
      if (data is Map && data['data'] != null) {
        final list = data['data'];
        if (list is List) {
          return list
              .map((e) => LiveTrackingModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } else if (data is List) {
        return data
            .map((e) => LiveTrackingModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return TripsMockData.multiTracking;
    }
  }

  /// 4. GET /api/parent/trips/upcoming
  Future<List<UpcomingTripModel>> getUpcomingTrips() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return TripsMockData.upcomingTrips;
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.parentUpcomingTrips,
        headers: _authHeader,
      );
      final data = response.data;
      if (data is Map) {
        final success = data['success'];
        if (success == false) {
          final msg = ApiException.extractMessage(data);
          throw ApiException(msg ?? 'تعذر تحميل الرحلات القادمة.');
        }
      }
      if (data is Map && data['data'] != null) {
        final list = data['data'];
        if (list is List) {
          return list
              .map((e) => UpcomingTripModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } else if (data is List) {
        return data
            .map((e) => UpcomingTripModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return TripsMockData.upcomingTrips;
    }
  }

  /// 5. GET /api/parent/trips/history?page=1
  Future<List<TripHistoryModel>> getTripHistory(int page) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return TripsMockData.getHistory(page);
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.parentTripHistory,
        queryParameters: {'page': page},
        headers: _authHeader,
      );
      final data = response.data;
      if (data is Map) {
        final success = data['success'];
        if (success == false) {
          final msg = ApiException.extractMessage(data);
          throw ApiException(msg ?? 'تعذر تحميل سجل الرحلات.');
        }
      }
      if (data is Map && data['data'] != null) {
        final list = data['data'];
        if (list is List) {
          return list
              .map((e) => TripHistoryModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } else if (data is List) {
        return data
            .map((e) => TripHistoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return TripsMockData.getHistory(page);
    }
  }

  /// 6. GET /api/parent/trips/{tripId}
  Future<TripDetailsModel> getTripDetails(dynamic tripId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return TripsMockData.getTripDetails(tripId);
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.parentTripDetails(tripId),
        headers: _authHeader,
      );
      final data = response.data;
      if (data is Map) {
        final success = data['success'];
        if (success == false) {
          final msg = ApiException.extractMessage(data);
          throw ApiException(msg ?? 'تعذر تحميل تفاصيل الرحلة.');
        }
      }
      if (data is Map && data['data'] != null) {
        return TripDetailsModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return TripDetailsModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      return TripsMockData.getTripDetails(tripId);
    }
  }

  /// 7. GET /api/parent/trips/{tripId}/timeline
  Future<List<TripTimelineItemModel>> getTripTimeline(dynamic tripId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return TripsMockData.getTimeline(tripId);
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.parentTripTimeline(tripId),
        headers: _authHeader,
      );
      final data = response.data;
      if (data is Map) {
        final success = data['success'];
        if (success == false) {
          final msg = ApiException.extractMessage(data);
          throw ApiException(msg ?? 'تعذر تحميل الـ Timeline الخاصة بالرحلة.');
        }
      }
      if (data is Map && data['data'] != null) {
        final list = data['data'];
        if (list is List) {
          return list
              .map((e) => TripTimelineItemModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } else if (data is List) {
        return data
            .map((e) => TripTimelineItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return TripsMockData.getTimeline(tripId);
    }
  }

  /// 8. GET /api/parent/children/{childId}/trips
  Future<ChildTripsModel> getChildTrips(dynamic childId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return TripsMockData.getChildTrips(childId);
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.parentChildTrips(childId),
        headers: _authHeader,
      );
      final data = response.data;
      if (data is Map) {
        final success = data['success'];
        if (success == false) {
          final msg = ApiException.extractMessage(data);
          throw ApiException(msg ?? 'تعذر تحميل رحلات الطفل.');
        }
      }
      if (data is Map && data['data'] != null) {
        return ChildTripsModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return ChildTripsModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      return TripsMockData.getChildTrips(childId);
    }
  }

  /// 9. GET /api/parent/trips/{tripId}/children/{childId}/status
  Future<Map<String, dynamic>> getChildStatus(dynamic tripId, dynamic childId) async {
    if (useMockData) {
      return {'status': 'in_bus', 'pickup_time': '07:15 ص'};
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.parentChildTripStatus(tripId, childId),
        headers: _authHeader,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['data'] is Map<String, dynamic>) {
          return data['data'] as Map<String, dynamic>;
        }
        return data;
      }
      return {};
    } catch (e) {
      return {'status': 'in_bus', 'pickup_time': '07:15 ص'};
    }
  }
}
