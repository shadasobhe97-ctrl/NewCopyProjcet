class OriginalDriverModel {
  final int id;
  final String name;
  final String phone;

  OriginalDriverModel({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory OriginalDriverModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] is Map ? Map<String, dynamic>.from(json['user'] as Map) : <String, dynamic>{};
    return OriginalDriverModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ??
          userMap['full_name']?.toString() ??
          json['full_name']?.toString() ??
          'السائق الأصلي',
      phone: json['phone']?.toString() ??
          userMap['phone_number']?.toString() ??
          json['phone_number']?.toString() ??
          '',
    );
  }
}

class DispatchChildInfo {
  final int id;
  final String fullName;
  final String? schoolName;

  DispatchChildInfo({
    required this.id,
    required this.fullName,
    this.schoolName,
  });

  factory DispatchChildInfo.fromJson(Map<String, dynamic> json) {
    final schoolMap = json['school'] is Map ? Map<String, dynamic>.from(json['school'] as Map) : <String, dynamic>{};
    return DispatchChildInfo(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      fullName: json['full_name']?.toString() ?? json['name']?.toString() ?? '',
      schoolName: schoolMap['name']?.toString() ?? json['school_name']?.toString(),
    );
  }
}

class DispatchStopInfo {
  final int id;
  final String stopType;
  final int sequenceOrder;
  final String status;
  final String label;
  final double lat;
  final double lng;
  final DispatchChildInfo? child;

  DispatchStopInfo({
    required this.id,
    required this.stopType,
    required this.sequenceOrder,
    required this.status,
    required this.label,
    required this.lat,
    required this.lng,
    this.child,
  });

  factory DispatchStopInfo.fromJson(Map<String, dynamic> json) {
    final childMap = json['child'] is Map ? Map<String, dynamic>.from(json['child'] as Map) : null;
    return DispatchStopInfo(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      stopType: json['stop_type']?.toString() ?? 'home',
      sequenceOrder: int.tryParse(json['sequence_order']?.toString() ?? '') ?? 1,
      status: json['status']?.toString() ?? 'pending',
      label: json['label']?.toString() ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? json['latitude']?.toString() ?? '') ?? 0.0,
      lng: double.tryParse(json['lng']?.toString() ?? json['longitude']?.toString() ?? '') ?? 0.0,
      child: childMap != null ? DispatchChildInfo.fromJson(childMap) : null,
    );
  }
}

class DispatchTripInfo {
  final int id;
  final String tripType;
  final String status;
  final List<DispatchStopInfo> stops;

  DispatchTripInfo({
    required this.id,
    required this.tripType,
    required this.status,
    required this.stops,
  });

  factory DispatchTripInfo.fromJson(Map<String, dynamic> json) {
    final rawStops = json['stops'] is List ? json['stops'] as List : [];
    final stopsList = rawStops
        .whereType<Map>()
        .map((e) => DispatchStopInfo.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return DispatchTripInfo(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      tripType: json['trip_type']?.toString() ?? 'morning',
      status: json['status']?.toString() ?? 'suspended_breakdown',
      stops: stopsList,
    );
  }
}

class EmergencyDispatchModel {
  final int id;
  final int tripId;
  final String status;
  final double breakdownLat;
  final double breakdownLng;
  final double tripFareAmount;
  final String? expiresAt;
  final String? reason;
  final int strandedChildrenCount;
  final int? substituteTripId;
  final int? substituteDriverId;
  final OriginalDriverModel? originalDriver;
  final DispatchTripInfo? trip;

  EmergencyDispatchModel({
    required this.id,
    required this.tripId,
    required this.status,
    required this.breakdownLat,
    required this.breakdownLng,
    required this.tripFareAmount,
    this.substituteTripId,
    this.substituteDriverId,
    this.expiresAt,
    this.reason,
    this.strandedChildrenCount = 0,
    this.originalDriver,
    this.trip,
  });

  bool get isBroadcasted => status == 'broadcasted';
  bool get isAccepted => status == 'accepted';

  factory EmergencyDispatchModel.fromJson(Map<String, dynamic> json) {
    final origDriverMap = json['original_driver'] is Map
        ? Map<String, dynamic>.from(json['original_driver'] as Map)
        : (json['driver'] is Map
            ? Map<String, dynamic>.from(json['driver'] as Map)
            : (json['originalDriver'] is Map
                ? Map<String, dynamic>.from(json['originalDriver'] as Map)
                : null));

    final tripMap = json['trip'] is Map
        ? Map<String, dynamic>.from(json['trip'] as Map)
        : (json['trip_info'] is Map
            ? Map<String, dynamic>.from(json['trip_info'] as Map)
            : null);

    return EmergencyDispatchModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      tripId: int.tryParse(json['trip_id']?.toString() ?? json['tripId']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? 'broadcasted',
      substituteTripId: int.tryParse(json['substitute_trip_id']?.toString() ?? json['substituteTripId']?.toString() ?? ''),
      substituteDriverId: int.tryParse(json['substitute_driver_id']?.toString() ?? json['substituteDriverId']?.toString() ?? ''),
      breakdownLat: double.tryParse(
              json['breakdown_lat']?.toString() ??
                  json['breakdown_latitude']?.toString() ??
                  json['lat']?.toString() ??
                  json['latitude']?.toString() ??
                  '') ??
          0.0,
      breakdownLng: double.tryParse(
              json['breakdown_lng']?.toString() ??
                  json['breakdown_longitude']?.toString() ??
                  json['lng']?.toString() ??
                  json['longitude']?.toString() ??
                  '') ??
          0.0,
      tripFareAmount: double.tryParse(
              json['trip_fare_amount']?.toString() ??
                  json['fare_amount']?.toString() ??
                  json['fare']?.toString() ??
                  json['amount']?.toString() ??
                  '') ??
          0.0,
      expiresAt: json['expires_at']?.toString() ?? json['expiresAt']?.toString(),
      reason: json['reason']?.toString(),
      strandedChildrenCount: int.tryParse(
              json['stranded_children_count']?.toString() ??
                  json['children_count']?.toString() ??
                  json['remaining_children_count']?.toString() ??
                  json['stranded_count']?.toString() ??
                  '') ??
          (json['stranded_children_ids'] is List
              ? (json['stranded_children_ids'] as List).length
              : (json['children_ids'] is List
                  ? (json['children_ids'] as List).length
                  : 0)),
      originalDriver:
          origDriverMap != null ? OriginalDriverModel.fromJson(origDriverMap) : null,
      trip: tripMap != null ? DispatchTripInfo.fromJson(tripMap) : null,
    );
  }
}
