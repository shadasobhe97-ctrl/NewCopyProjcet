import 'active_trip_model.dart';

class LiveTrackingModel {
  final int tripId;
  final String status;
  final double driverLat;
  final double driverLng;
  final DestinationInfo? destination;
  final String lastUpdated;
  final bool isOnline;

  const LiveTrackingModel({
    required this.tripId,
    required this.status,
    required this.driverLat,
    required this.driverLng,
    this.destination,
    required this.lastUpdated,
    this.isOnline = true,
  });

  factory LiveTrackingModel.fromJson(Map<String, dynamic> json) {
    double lat = 0.0;
    double lng = 0.0;

    if (json['driver_location'] is Map<String, dynamic>) {
      final loc = json['driver_location'] as Map<String, dynamic>;
      lat = (loc['lat'] as num?)?.toDouble() ?? (loc['latitude'] as num?)?.toDouble() ?? 0.0;
      lng = (loc['lng'] as num?)?.toDouble() ?? (loc['longitude'] as num?)?.toDouble() ?? 0.0;
    } else {
      lat = (json['driver_lat'] as num?)?.toDouble() ?? (json['lat'] as num?)?.toDouble() ?? 0.0;
      lng = (json['driver_lng'] as num?)?.toDouble() ?? (json['lng'] as num?)?.toDouble() ?? 0.0;
    }

    DestinationInfo? dest;
    if (json['destination'] is Map<String, dynamic>) {
      dest = DestinationInfo.fromJson(json['destination'] as Map<String, dynamic>);
    }

    return LiveTrackingModel(
      tripId: json['trip_id'] as int? ?? json['id'] as int? ?? 0,
      status: json['status']?.toString() ?? 'active',
      driverLat: lat,
      driverLng: lng,
      destination: dest,
      lastUpdated: json['last_updated']?.toString() ?? 'الآن',
      isOnline: json['is_online'] as bool? ?? true,
    );
  }
}

typedef TripTrackModel = LiveTrackingModel;
