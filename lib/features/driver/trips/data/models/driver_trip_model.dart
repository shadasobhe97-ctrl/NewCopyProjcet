import 'package:equatable/equatable.dart';

/// غلاف استجابة رحلات اليوم (GET /v1/driver/trips/today?date=YYYY-MM-DD)
class DriverTripsTodayResponseModel extends Equatable {
  final String status;
  final String? date;
  final List<DriverTripModel> trips;

  const DriverTripsTodayResponseModel({
    required this.status,
    this.date,
    required this.trips,
  });

  factory DriverTripsTodayResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final tripsList = (rawList is List)
        ? rawList
            .whereType<Map>()
            .map((e) => DriverTripModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <DriverTripModel>[];

    return DriverTripsTodayResponseModel(
      status: json['status']?.toString() ?? 'success',
      date: json['date']?.toString(),
      trips: tripsList,
    );
  }

  @override
  List<Object?> get props => [status, date, trips];
}

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
  final String? tripDate;
  final String? date;

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
    this.tripDate,
    this.date,
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
      tripDate: json['trip_date']?.toString(),
      date: json['date']?.toString(),
    );
  }

  bool get isPending => status == 'pending' || status == 'scheduled';
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
        tripDate,
        date,
      ];
}
