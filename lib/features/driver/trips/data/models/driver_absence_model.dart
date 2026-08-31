import 'package:equatable/equatable.dart';

/// رحلة قادمة متاحة لتسجيل الغياب عنها (GET /api/v1/driver/trips/upcoming-for-absence)
class UpcomingAbsenceTripModel extends Equatable {
  final int id;
  final String tripType;
  final String? shiftSlot;
  final String tripDate;
  final String? scheduledStartTime;
  final String status;
  final String routeName;

  const UpcomingAbsenceTripModel({
    required this.id,
    required this.tripType,
    this.shiftSlot,
    required this.tripDate,
    this.scheduledStartTime,
    required this.status,
    required this.routeName,
  });

  factory UpcomingAbsenceTripModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return UpcomingAbsenceTripModel(
      id: parseInt(json['id'] ?? json['trip_id']),
      tripType: json['trip_type']?.toString() ?? 'Morning',
      shiftSlot: json['shift_slot']?.toString(),
      tripDate: json['trip_date']?.toString() ?? '',
      scheduledStartTime: json['scheduled_start_time']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      routeName: json['route_name']?.toString() ?? json['route']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_type': tripType,
      'shift_slot': shiftSlot,
      'trip_date': tripDate,
      'scheduled_start_time': scheduledStartTime,
      'status': status,
      'route_name': routeName,
    };
  }

  @override
  List<Object?> get props => [
        id,
        tripType,
        shiftSlot,
        tripDate,
        scheduledStartTime,
        status,
        routeName,
      ];
}

/// طلب تسجيل الغياب للرحلات المحددة (POST /api/v1/driver/trips/register-absence)
class DriverRegisterAbsenceRequestModel extends Equatable {
  final String date;
  final List<int> tripIds;
  final String reason;

  const DriverRegisterAbsenceRequestModel({
    required this.date,
    required this.tripIds,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'trip_ids': tripIds,
      'reason': reason,
    };
  }

  @override
  List<Object?> get props => [date, tripIds, reason];
}

/// استجابة تسجيل الغياب المباشر والاعتماد الفوري (status = approved)
class DriverRegisterAbsenceResponseModel extends Equatable {
  final int absenceId;
  final int driverId;
  final String absenceDate;
  final String reason;
  final String status;
  final List<int> tripIds;
  final List<UpcomingAbsenceTripModel> trips;

  const DriverRegisterAbsenceResponseModel({
    required this.absenceId,
    required this.driverId,
    required this.absenceDate,
    required this.reason,
    required this.status,
    required this.tripIds,
    required this.trips,
  });

  factory DriverRegisterAbsenceResponseModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    final rawTrips = json['trips'];
    final tripsList = (rawTrips is List)
        ? rawTrips
            .whereType<Map>()
            .map((e) => UpcomingAbsenceTripModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <UpcomingAbsenceTripModel>[];

    final rawTripIds = json['trip_ids'];
    final tripIdsList = (rawTripIds is List)
        ? rawTripIds.map((e) => parseInt(e)).toList()
        : <int>[];

    return DriverRegisterAbsenceResponseModel(
      absenceId: parseInt(json['absence_id'] ?? json['id']),
      driverId: parseInt(json['driver_id']),
      absenceDate: json['absence_date']?.toString() ?? json['date']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'approved',
      tripIds: tripIdsList,
      trips: tripsList,
    );
  }

  bool get isApproved => status == 'approved';

  @override
  List<Object?> get props => [
        absenceId,
        driverId,
        absenceDate,
        reason,
        status,
        tripIds,
        trips,
      ];
}
