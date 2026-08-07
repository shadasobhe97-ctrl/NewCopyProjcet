import 'package:equatable/equatable.dart';

/// محطة رحلة واحدة (GET /driver/trips/{tripId}/stops)
class DriverTripStopModel extends Equatable {
  final int id;
  final String stopType; // home | school
  final int sequenceOrder;
  final String status; // trip_stops.status values
  final int? childId;
  final String? childName;
  final int? schoolId;
  final String? schoolName;
  final String label;
  final double latitude;
  final double longitude;
  final String? eta;
  final int? etaMinutes;

  const DriverTripStopModel({
    required this.id,
    required this.stopType,
    required this.sequenceOrder,
    required this.status,
    required this.childId,
    required this.childName,
    required this.schoolId,
    required this.schoolName,
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.eta,
    required this.etaMinutes,
  });

  factory DriverTripStopModel.fromJson(Map<String, dynamic> json) {
    return DriverTripStopModel(
      id: _parseInt(json['id']),
      stopType: json['stop_type']?.toString() ?? '',
      sequenceOrder: _parseInt(json['sequence_order']),
      status: json['status']?.toString() ?? 'pending',
      childId: json['child_id'] == null ? null : _parseInt(json['child_id']),
      childName: json['child_name']?.toString(),
      schoolId: json['school_id'] == null ? null : _parseInt(json['school_id']),
      schoolName: json['school_name']?.toString(),
      label: json['label']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      eta: json['eta']?.toString(),
      etaMinutes: json['eta_minutes'] == null ? null : _parseInt(json['eta_minutes']),
    );
  }

  bool get isHome => stopType == 'home';
  bool get isSchool => stopType == 'school';
  bool get isResolved => status != 'pending' && status != 'boarded';

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic val) {
    if (val is double) return val;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  @override
  List<Object?> get props => [
        id,
        stopType,
        sequenceOrder,
        status,
        childId,
        childName,
        schoolId,
        schoolName,
        label,
        latitude,
        longitude,
        eta,
        etaMinutes,
      ];
}

/// غلاف استجابة نقطة المحطات
class DriverTripStopsResponseModel extends Equatable {
  final int tripId;
  final String tripStatus;
  final List<DriverTripStopModel> stops;

  const DriverTripStopsResponseModel({
    required this.tripId,
    required this.tripStatus,
    required this.stops,
  });

  factory DriverTripStopsResponseModel.fromJson(Map<String, dynamic> json) {
    return DriverTripStopsResponseModel(
      tripId: DriverTripStopModel._parseInt(json['trip_id']),
      tripStatus: json['trip_status']?.toString() ?? 'pending',
      stops: json['stops'] is List
          ? (json['stops'] as List)
              .whereType<Map>()
              .map((e) => DriverTripStopModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  @override
  List<Object?> get props => [tripId, tripStatus, stops];
}
