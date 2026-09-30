import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore _firestore;

  TripsRemoteDataSource(
    this._apiClient, {
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  /// 🌟 0. Stream Live Tracking from Firebase Firestore: trips_tracking/{tripId}
  Stream<LiveTrackingModel> trackTripLiveStream(
    int tripId,
    LiveTrackingModel baseModel,
  ) {
    return _firestore
        .collection('trips_tracking')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return baseModel;
      }

      final data = _findBestDocWithLocation(
        snapshot.docs,
        tripId,
        baseModel.driverId,
      );

      if (data == null) {
        return baseModel;
      }

      final loc = _extractLocationFromMap(data);
      final double driverLat = loc['lat'] != 0.0 ? loc['lat']! : baseModel.driverLat;
      final double driverLng = loc['lng'] != 0.0 ? loc['lng']! : baseModel.driverLng;

      final double heading = _parseDouble(
        data['heading'] ?? data['driver_heading'] ?? data['bearing'],
        baseModel.heading ?? 0.0,
      );
      final double speed = _parseDouble(
        data['speed'],
        baseModel.speed ?? 0.0,
      );
      final String status = data['status']?.toString() ?? baseModel.status;

      debugPrint(
        '\n🔥 ==================== [FIREBASE LIVE TRACKING UPDATE] ====================\n'
        '📌 Target Trip ID: $tripId | Driver ID: ${baseModel.driverId}\n'
        '🚗 Driver Location Extracted: Lat = $driverLat, Lng = $driverLng\n'
        '🧭 Heading: $heading° | Speed: $speed km/h | Status: $status\n'
        '=========================================================================\n',
      );

      return baseModel.copyWith(
        driverLat: driverLat,
        driverLng: driverLng,
        heading: heading,
        speed: speed,
        status: status,
        lastUpdated: 'الآن',
        isOnline: true,
      );
    });
  }

  /// 🌟 5-Tier Resolver to find document with valid live coordinates in Firestore
  static Map<String, dynamic>? _findBestDocWithLocation(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    int tripId,
    int? driverId,
  ) {
    final String docIdStr = tripId.toString();

    // 1. Try exact doc ID match WITH valid location
    for (final doc in docs) {
      if (doc.id == docIdStr) {
        final loc = _extractLocationFromMap(doc.data());
        if (loc['lat'] != 0.0 && loc['lng'] != 0.0) {
          return doc.data();
        }
      }
    }

    // 2. Try trip_id field match WITH valid location
    for (final doc in docs) {
      final docData = doc.data();
      final parsedId = (docData['trip_id'] as num?)?.toInt() ??
          int.tryParse(docData['trip_id']?.toString() ?? '');
      if (parsedId == tripId) {
        final loc = _extractLocationFromMap(docData);
        if (loc['lat'] != 0.0 && loc['lng'] != 0.0) {
          return docData;
        }
      }
    }

    // 3. Try driver_id field match WITH valid location
    if (driverId != null && driverId != 0) {
      for (final doc in docs) {
        final docData = doc.data();
        final parsedDriverId = (docData['driver_id'] as num?)?.toInt() ??
            int.tryParse(docData['driver_id']?.toString() ?? '');
        if (parsedDriverId == driverId) {
          final loc = _extractLocationFromMap(docData);
          if (loc['lat'] != 0.0 && loc['lng'] != 0.0) {
            return docData;
          }
        }
      }
    }

    // 4. Fallback: find ANY active doc in collection that HAS valid non-zero location
    for (final doc in docs) {
      final loc = _extractLocationFromMap(doc.data());
      if (loc['lat'] != 0.0 && loc['lng'] != 0.0) {
        return doc.data();
      }
    }

    // 5. Last resort: return doc matching exact ID even if lat is 0
    for (final doc in docs) {
      if (doc.id == docIdStr) {
        return doc.data();
      }
    }

    return docs.isNotEmpty ? docs.first.data() : null;
  }

      final loc = _extractLocationFromMap(data);
      final double driverLat = loc['lat'] != 0.0 ? loc['lat']! : baseModel.driverLat;
      final double driverLng = loc['lng'] != 0.0 ? loc['lng']! : baseModel.driverLng;

      final double heading = _parseDouble(
        data['heading'] ?? data['driver_heading'] ?? data['bearing'],
        baseModel.heading ?? 0.0,
      );
      final double speed = _parseDouble(
        data['speed'],
        baseModel.speed ?? 0.0,
      );
      final String status = data['status']?.toString() ?? baseModel.status;

      debugPrint(
        '\n🔥 ==================== [FIREBASE LIVE TRACKING UPDATE] ====================\n'
        '📌 Firestore Doc: $matchedDocId | Target Trip ID: $tripId\n'
        '🚗 Driver Location: Lat = $driverLat, Lng = $driverLng\n'
        '🧭 Heading: $heading° | Speed: $speed km/h | Status: $status\n'
        '=========================================================================\n',
      );

      return baseModel.copyWith(
        driverLat: driverLat,
        driverLng: driverLng,
        heading: heading,
        speed: speed,
        status: status,
        lastUpdated: 'الآن',
        isOnline: true,
      );
    });
  }

  /// 🌟 Robust location extractor that handles GeoPoint, nested maps, and all key variants
  static Map<String, double> _extractLocationFromMap(Map<String, dynamic> data) {
    double lat = 0.0;
    double lng = 0.0;

    // 1. Check GeoPoint objects (Firestore native location type)
    for (final key in ['location', 'driver_location', 'position', 'coords', 'geo']) {
      final val = data[key];
      if (val is GeoPoint) {
        return {'lat': val.latitude, 'lng': val.longitude};
      }
    }

    // 2. Check nested maps: data['driver_location'], data['location'], data['driver']
    for (final key in ['driver_location', 'location', 'driver', 'position', 'coords']) {
      final val = data[key];
      if (val is Map) {
        final map = Map<String, dynamic>.from(val);
        final nestedLat = _parseDouble(
          map['driver_lat'] ?? map['latitude'] ?? map['lat'] ?? map['current_lat'] ?? map['driverLat'],
        );
        final nestedLng = _parseDouble(
          map['driver_lng'] ?? map['longitude'] ?? map['lng'] ?? map['current_lng'] ?? map['driverLng'],
        );
        if (nestedLat != 0.0 && nestedLng != 0.0) {
          return {'lat': nestedLat, 'lng': nestedLng};
        }
      }
    }

    // 3. Check flat fields: driver_lat/lng, latitude/longitude, lat/lng, driverLat/driverLng, current_lat/lng
    lat = _parseDouble(
      data['driver_lat'] ??
          data['latitude'] ??
          data['lat'] ??
          data['driverLat'] ??
          data['current_lat'] ??
          data['lat_val'],
    );

    lng = _parseDouble(
      data['driver_lng'] ??
          data['longitude'] ??
          data['lng'] ??
          data['driverLng'] ??
          data['current_lng'] ??
          data['lng_val'],
    );

    return {'lat': lat, 'lng': lng};
  }

  static double _parseDouble(dynamic val, [double defaultValue = 0.0]) {
    if (val is double) return val;
    if (val is num) return val.toDouble();
    if (val != null) return double.tryParse(val.toString()) ?? defaultValue;
    return defaultValue;
  }

  /// 🌟 Stream Multiple Active Trips Live Tracking from Firebase Firestore
  Stream<List<LiveTrackingModel>> trackMultipleTripsLiveStream() {
    return _firestore.collection('trips_tracking').snapshots().map((snapshot) {
      final List<LiveTrackingModel> list = [];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final parsedTripId =
            int.tryParse(doc.id) ?? (data['trip_id'] as num?)?.toInt() ?? 0;
        final loc = _extractLocationFromMap(data);
        final double driverLat = loc['lat']!;
        final double driverLng = loc['lng']!;
        final double heading = _parseDouble(
          data['heading'] ?? data['driver_heading'] ?? data['bearing'],
        );

        debugPrint(
          '🔥 [Firestore Multi-Tracking Update] Trip ID: ${doc.id} | '
          'Lat: $driverLat | Lng: $driverLng | Heading: $heading°',
        );

        list.add(
          LiveTrackingModel(
            tripId: parsedTripId,
            status: data['status']?.toString() ?? 'active',
            driverLat: driverLat,
            driverLng: driverLng,
            heading: heading,
            speed: _parseDouble(data['speed']),
            lastUpdated: 'الآن',
            isOnline: true,
          ),
        );
      }
      return list;
    });
  }

  /// 1. GET /api/parent/trips/active
  Future<List<ActiveTripModel>> getActiveTrips() async {
    final response = await _apiClient.get(
      ApiEndpoints.parentActiveTrips,
      headers: _authHeader,
    );
    final data = response.data;

    debugPrint(
      '\n🌐 ==================== [BACKEND REST API: GET active-trips] ====================\n'
      'URL: ${ApiEndpoints.parentActiveTrips}\n'
      'Raw Response Data: $data\n'
      '=================================================================================\n',
    );

    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false || success == 'error') {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل الرحلات النشطة.');
      }
    }
    final payload = (data is Map && data['data'] != null) ? data['data'] : data;
    if (payload is List) {
      final trips = payload
          .map((e) => ActiveTripModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      for (final trip in trips) {
        debugPrint(
          '📦 [ActiveTrip] Trip ID: ${trip.tripId} | Status: ${trip.status} | Direction: ${trip.direction}\n'
          '   Driver: ${trip.driver.name} (ID: ${trip.driver.id}, Phone: ${trip.driver.phone})\n'
          '   Destination: ${trip.destination.name} (Type: ${trip.destination.type}, Lat: ${trip.destination.lat}, Lng: ${trip.destination.lng})\n'
          '   Children Count: ${trip.children.length}',
        );
        for (final child in trip.children) {
          debugPrint(
            '   👶 Child: ${child.childName} (ID: ${child.childId}, Status: ${child.childStatus})\n'
            '      🏠 Home: ${child.homeAddress?.title} -> Lat: ${child.homeAddress?.lat}, Lng: ${child.homeAddress?.lng}\n'
            '      🏫 School: ${child.school?.name} -> Lat: ${child.school?.lat}, Lng: ${child.school?.lng}',
          );
        }
      }
      return trips;
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

    debugPrint(
      '\n🌐 ==================== [BACKEND REST API: GET trip-track] ====================\n'
      'Trip ID: $tripId | URL: ${ApiEndpoints.parentTripTrack(tripId)}\n'
      'Raw Response Data: $data\n'
      '=================================================================================\n',
    );

    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false || success == 'error') {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل مسار الرحلة.');
      }
    }
    LiveTrackingModel model;
    if (data is Map && data['data'] != null) {
      model = LiveTrackingModel.fromJson(
          Map<String, dynamic>.from(data['data'] as Map));
    } else if (data is Map<String, dynamic>) {
      model = LiveTrackingModel.fromJson(data);
    } else {
      throw ApiException('استجابة غير متوقعة عند جلب مسار الرحلة.');
    }

    debugPrint(
      '📌 [TripTrack Initial Data] Trip ID: ${model.tripId} | '
      'Driver Initial Lat: ${model.driverLat}, Lng: ${model.driverLng}\n'
      '   Destination: ${model.destination?.name} (${model.destination?.type}) -> Lat: ${model.destination?.lat}, Lng: ${model.destination?.lng}\n'
      '   Children tracked: ${model.children.length}',
    );

    return model;
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
