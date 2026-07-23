import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/active_trip_model.dart';
import '../models/trip_track_model.dart';
import '../models/upcoming_trip_model.dart';
import '../models/trip_history_model.dart';

class TripsRemoteDataSource {
  final ApiClient _apiClient;

  TripsRemoteDataSource(this._apiClient);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  Future<List<ActiveTripModel>> getActiveTrips() async {
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
      return (data as List)
          .map((e) => ActiveTripModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<TripTrackModel> getTripTrack(int tripId) async {
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
      return TripTrackModel.fromJson(
          data['data'] as Map<String, dynamic>);
    }
    return TripTrackModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<UpcomingTripModel>> getUpcomingTrips() async {
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
      return (data as List)
          .map((e) => UpcomingTripModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<TripHistoryModel>> getTripHistory(int page) async {
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
      return (data as List)
          .map((e) => TripHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
