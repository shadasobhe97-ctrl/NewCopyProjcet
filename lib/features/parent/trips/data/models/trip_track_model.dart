import 'active_trip_model.dart';

class TrackingChildInfo {
  final int childId;
  final String childName;
  final String status;
  final ChildAddressModel? home;
  final ChildSchoolModel? school;

  const TrackingChildInfo({
    required this.childId,
    required this.childName,
    required this.status,
    this.home,
    this.school,
  });

  factory TrackingChildInfo.fromJson(Map<String, dynamic> json) {
    ChildAddressModel? homeObj;
    if (json['home'] is Map<String, dynamic>) {
      homeObj = ChildAddressModel.fromJson(json['home'] as Map<String, dynamic>);
    } else if (json['home_location'] is Map<String, dynamic>) {
      homeObj = ChildAddressModel.fromJson(json['home_location'] as Map<String, dynamic>);
    } else if (json['home_address'] is Map<String, dynamic>) {
      homeObj = ChildAddressModel.fromJson(json['home_address'] as Map<String, dynamic>);
    }

    ChildSchoolModel? schoolObj;
    if (json['school'] is Map<String, dynamic>) {
      schoolObj = ChildSchoolModel.fromJson(json['school'] as Map<String, dynamic>);
    } else if (json['school_location'] is Map<String, dynamic>) {
      schoolObj = ChildSchoolModel.fromJson(json['school_location'] as Map<String, dynamic>);
    }

    return TrackingChildInfo(
      childId: _parseInt(json['child_id'] ?? json['id']),
      childName: json['child_name']?.toString() ?? json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? json['child_status']?.toString() ?? '',
      home: homeObj,
      school: schoolObj,
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
  final double? heading;
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
    this.heading,
    this.destination,
    this.children = const [],
    required this.lastUpdated,
    this.isOnline = true,
  });

  bool get isToSchool => destination?.type.toLowerCase() == 'school';
  bool get isToHome => destination?.type.toLowerCase() == 'home';

  List<ChildSchoolModel> get uniqueSchools {
    final Map<String, ChildSchoolModel> map = {};
    for (final child in children) {
      if (child.school != null && child.school!.lat != 0.0) {
        final key = '${child.school!.id}_${child.school!.lat}_${child.school!.lng}';
        map[key] = child.school!;
      }
    }
    return map.values.toList();
  }

  List<ChildAddressModel> get uniqueHomeAddresses {
    final Map<String, ChildAddressModel> map = {};
    for (final child in children) {
      if (child.home != null && child.home!.lat != 0.0) {
        final key = '${child.home!.title}_${child.home!.lat}_${child.home!.lng}';
        map[key] = child.home!;
      }
    }
    return map.values.toList();
  }

  LiveTrackingModel copyWith({
    int? tripId,
    int? driverId,
    String? driverName,
    String? status,
    double? driverLat,
    double? driverLng,
    double? speed,
    double? heading,
    DestinationInfo? destination,
    List<TrackingChildInfo>? children,
    String? lastUpdated,
    bool? isOnline,
  }) {
    return LiveTrackingModel(
      tripId: tripId ?? this.tripId,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      status: status ?? this.status,
      driverLat: driverLat ?? this.driverLat,
      driverLng: driverLng ?? this.driverLng,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      destination: destination ?? this.destination,
      children: children ?? this.children,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  factory LiveTrackingModel.fromJson(Map<String, dynamic> json) {
    double lat = 0.0;
    double lng = 0.0;

    if (json['driver_location'] is Map<String, dynamic>) {
      final loc = json['driver_location'] as Map<String, dynamic>;
      lat = _parseDouble(loc['lat'] ?? loc['latitude']);
      lng = _parseDouble(loc['lng'] ?? loc['longitude']);
    } else {
      lat = _parseDouble(json['driver_lat'] ?? json['lat']);
      lng = _parseDouble(json['driver_lng'] ?? json['lng']);
    }

    final double? headingVal = _parseNullableDouble(
      json['heading'] ?? json['driver_heading'] ?? json['bearing'],
    );

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
      speed: _parseNullableDouble(json['speed']),
      heading: headingVal,
      destination: dest,
      children: childrenList,
      lastUpdated: json['last_updated']?.toString() ?? 'الآن',
      isOnline: json['is_online'] as bool? ?? true,
    );
  }

  static double _parseDouble(dynamic val) {
    if (val is double) return val;
    if (val is num) return val.toDouble();
    if (val != null) return double.tryParse(val.toString()) ?? 0.0;
    return 0.0;
  }

  static double? _parseNullableDouble(dynamic val) {
    if (val is double) return val;
    if (val is num) return val.toDouble();
    if (val != null) return double.tryParse(val.toString());
    return null;
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
