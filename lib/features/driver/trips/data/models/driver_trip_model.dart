import 'package:equatable/equatable.dart';

/// عنصر رحلة في قائمة "رحلات اليوم"
class DriverTripModel extends Equatable {
  final int tripId;
  final int? routeId;
  final String routeName;
  final String tripType;
  final String status;
  final int childrenCount;
  final int schoolsCount;
  final int estimatedDuration;
  final String? recommendedDeparture;
  final String? startedAt;

  const DriverTripModel({
    required this.tripId,
    required this.routeId,
    required this.routeName,
    required this.tripType,
    required this.status,
    required this.childrenCount,
    required this.schoolsCount,
    required this.estimatedDuration,
    required this.recommendedDeparture,
    required this.startedAt,
  });

  factory DriverTripModel.fromJson(Map<String, dynamic> json) {
    return DriverTripModel(
      tripId: _parseInt(json['trip_id']),
      routeId: json['route_id'] == null ? null : _parseInt(json['route_id']),
      routeName: json['route_name']?.toString() ?? '',
      tripType: json['trip_type']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      childrenCount: _parseInt(json['children_count']),
      schoolsCount: _parseInt(json['schools_count']),
      estimatedDuration: _parseInt(json['estimated_duration']),
      recommendedDeparture: json['recommended_departure']?.toString(),
      startedAt: json['started_at']?.toString(),
    );
  }

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isSuspended => status == 'suspended_breakdown';

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  @override
  List<Object?> get props => [
        tripId,
        routeId,
        routeName,
        tripType,
        status,
        childrenCount,
        schoolsCount,
        estimatedDuration,
        recommendedDeparture,
        startedAt,
      ];
}
