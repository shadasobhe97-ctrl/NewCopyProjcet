import 'active_trip_model.dart';

class TrackingChildInfo {
  final int childId;
  final String childName;
  final String status;

  const TrackingChildInfo({
    required this.childId,
    required this.childName,
    required this.status,
  });

  factory TrackingChildInfo.fromJson(Map<String, dynamic> json) {
    return TrackingChildInfo(
      childId: _parseInt(json['child_id'] ?? json['id']),
      childName: json['child_name']?.toString() ?? json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val != null) return int.tryParse(val.toString()) ?? 0;
    return 0;
  }
}

class LiveTrackingModel {
  final int tripId;
  final int? driverId;
  final String? driverName;
  final String status;
  final double driverLat;
  final double driverLng;
  final double? speed;
  final DestinationInfo? destination;
  final List<TrackingChildInfo> children;
  final String lastUpdated;
  final bool isOnline;

  const LiveTrackingModel({
    required this.tripId,
    this.driverId,
    this.driverName,
    required this.status,
    required this.driverLat,
    required this.driverLng,
    this.speed,
    this.destination,
    this.children = const [],
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
      dest = DestinationInfo.fromJson(Map<String, dynamic>.from(json['destination'] as Map));
    }

    List<TrackingChildInfo> childrenList = [];
    if (json['children'] is List) {
      childrenList = (json['children'] as List)
          .map((e) => TrackingChildInfo.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return LiveTrackingModel(
      tripId: _parseInt(json['trip_id'] ?? json['id']),
      driverId: _parseNullableInt(json['driver_id']),
      driverName: json['driver_name']?.toString(),
      status: json['status']?.toString() ?? 'active',
      driverLat: lat,
      driverLng: lng,
      speed: (json['speed'] as num?)?.toDouble(),
      destination: dest,
      children: childrenList,
      lastUpdated: json['last_updated']?.toString() ?? 'الآن',
      isOnline: json['is_online'] as bool? ?? true,
    );
  }

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val != null) return int.tryParse(val.toString()) ?? 0;
    return 0;
  }

  static int? _parseNullableInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val != null) return int.tryParse(val.toString());
    return null;
  }
}

typedef TripTrackModel = LiveTrackingModel;
