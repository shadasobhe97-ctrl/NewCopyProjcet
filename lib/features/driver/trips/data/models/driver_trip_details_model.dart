import 'package:equatable/equatable.dart';

/// تفاصيل رحلة كاملة (GET /driver/trips/{tripId})
class DriverTripDetailsModel extends Equatable {
  final int tripId;
  final String tripType;
  final String routeName;
  final String status;
  final String tripDate;
  final String? recommendedDeparture;
  final int estimatedDuration;
  final TripVehicleModel vehicle;
  final TripStatisticsModel statistics;
  final List<TripSchoolModel> schools;
  final List<TripDetailsChildModel> children;

  const DriverTripDetailsModel({
    required this.tripId,
    required this.tripType,
    required this.routeName,
    required this.status,
    required this.tripDate,
    required this.recommendedDeparture,
    required this.estimatedDuration,
    required this.vehicle,
    required this.statistics,
    required this.schools,
    required this.children,
  });

  factory DriverTripDetailsModel.fromJson(Map<String, dynamic> json) {
    return DriverTripDetailsModel(
      tripId: _parseInt(json['trip_id']),
      tripType: json['trip_type']?.toString() ?? '',
      routeName: json['route_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      tripDate: json['trip_date']?.toString() ?? '',
      recommendedDeparture: json['recommended_departure']?.toString(),
      estimatedDuration: _parseInt(json['estimated_duration']),
      vehicle: json['vehicle'] is Map
          ? TripVehicleModel.fromJson(Map<String, dynamic>.from(json['vehicle'] as Map))
          : TripVehicleModel.empty(),
      statistics: json['statistics'] is Map
          ? TripStatisticsModel.fromJson(Map<String, dynamic>.from(json['statistics'] as Map))
          : TripStatisticsModel.empty(),
      schools: json['schools'] is List
          ? (json['schools'] as List)
              .whereType<Map>()
              .map((e) => TripSchoolModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      children: json['children'] is List
          ? (json['children'] as List)
              .whereType<Map>()
              .map((e) => TripDetailsChildModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
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
        tripType,
        routeName,
        status,
        tripDate,
        recommendedDeparture,
        estimatedDuration,
        vehicle,
        statistics,
        schools,
        children,
      ];
}

class TripVehicleModel extends Equatable {
  final String plate;
  final int capacity;

  const TripVehicleModel({required this.plate, required this.capacity});

  factory TripVehicleModel.fromJson(Map<String, dynamic> json) {
    return TripVehicleModel(
      plate: json['plate']?.toString() ?? '',
      capacity: DriverTripDetailsModel._parseInt(json['capacity']),
    );
  }

  factory TripVehicleModel.empty() => const TripVehicleModel(plate: '', capacity: 0);

  @override
  List<Object?> get props => [plate, capacity];
}

class TripStatisticsModel extends Equatable {
  final int children;
  final int schools;

  const TripStatisticsModel({required this.children, required this.schools});

  factory TripStatisticsModel.fromJson(Map<String, dynamic> json) {
    return TripStatisticsModel(
      children: DriverTripDetailsModel._parseInt(json['children']),
      schools: DriverTripDetailsModel._parseInt(json['schools']),
    );
  }

  factory TripStatisticsModel.empty() => const TripStatisticsModel(children: 0, schools: 0);

  @override
  List<Object?> get props => [children, schools];
}

class TripSchoolModel extends Equatable {
  final int schoolId;
  final String name;
  final int childrenCount;

  const TripSchoolModel({
    required this.schoolId,
    required this.name,
    required this.childrenCount,
  });

  factory TripSchoolModel.fromJson(Map<String, dynamic> json) {
    return TripSchoolModel(
      schoolId: DriverTripDetailsModel._parseInt(json['school_id']),
      name: json['name']?.toString() ?? '',
      childrenCount: DriverTripDetailsModel._parseInt(json['children_count']),
    );
  }

  @override
  List<Object?> get props => [schoolId, name, childrenCount];
}

/// حالة طفل ضمن تفاصيل الرحلة
class TripDetailsChildModel extends Equatable {
  final int tripChildId;
  final int childId;
  final String name;
  final String school;
  final String pickupAddress;
  final String dropoffAddress;
  final String status;
  final String pickupStatus;
  final String dropoffStatus;
  final String? eta;
  final int sequenceOrder;

  const TripDetailsChildModel({
    required this.tripChildId,
    required this.childId,
    required this.name,
    required this.school,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.status,
    required this.pickupStatus,
    required this.dropoffStatus,
    required this.eta,
    required this.sequenceOrder,
  });

  factory TripDetailsChildModel.fromJson(Map<String, dynamic> json) {
    return TripDetailsChildModel(
      tripChildId: DriverTripDetailsModel._parseInt(json['trip_child_id']),
      childId: DriverTripDetailsModel._parseInt(json['child_id']),
      name: json['name']?.toString() ?? '',
      school: json['school']?.toString() ?? '',
      pickupAddress: json['pickup_address']?.toString() ?? '',
      dropoffAddress: json['dropoff_address']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      pickupStatus: json['pickup_status']?.toString() ?? 'pending',
      dropoffStatus: json['dropoff_status']?.toString() ?? 'pending',
      eta: json['eta']?.toString(),
      sequenceOrder: DriverTripDetailsModel._parseInt(json['sequence_order']),
    );
  }

  @override
  List<Object?> get props => [
        tripChildId,
        childId,
        name,
        school,
        pickupAddress,
        dropoffAddress,
        status,
        pickupStatus,
        dropoffStatus,
        eta,
        sequenceOrder,
      ];
}
