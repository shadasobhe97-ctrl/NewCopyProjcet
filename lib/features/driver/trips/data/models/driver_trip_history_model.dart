import 'package:equatable/equatable.dart';

/// عنصر في سجل الرحلات (GET /driver/trips/history)
class DriverTripHistoryModel extends Equatable {
  final int tripId;
  final String tripDate;
  final String routeName;
  final String status;
  final int duration;

  const DriverTripHistoryModel({
    required this.tripId,
    required this.tripDate,
    required this.routeName,
    required this.status,
    required this.duration,
  });

  factory DriverTripHistoryModel.fromJson(Map<String, dynamic> json) {
    return DriverTripHistoryModel(
      tripId: _parseInt(json['trip_id']),
      tripDate: json['trip_date']?.toString() ?? '',
      routeName: json['route_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      duration: _parseInt(json['duration']),
    );
  }

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  @override
  List<Object?> get props => [tripId, tripDate, routeName, status, duration];
}

/// طفل ضمن تفاصيل رحلة من السجل — عنصر موحّد واحد لكل طفل
/// (يجمع الصعود والنزول معاً، بنفس حقول تفاصيل الرحلة الحية).
class TripHistoryChildModel extends Equatable {
  final int childId;
  final String childName;
  final String school;
  final String pickupAddress;
  final String dropoffAddress;
  final String? pickupTime;
  final String? dropoffTime;
  final String? scannedPickupAt;
  final String? scannedDropoffAt;
  final String status;
  final String pickupStatus;
  final String dropoffStatus;

  const TripHistoryChildModel({
    required this.childId,
    required this.childName,
    required this.school,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupTime,
    required this.dropoffTime,
    required this.scannedPickupAt,
    required this.scannedDropoffAt,
    required this.status,
    required this.pickupStatus,
    required this.dropoffStatus,
  });

  factory TripHistoryChildModel.fromJson(Map<String, dynamic> json) {
    return TripHistoryChildModel(
      childId: DriverTripHistoryModel._parseInt(json['child_id']),
      childName: (json['child_name'] ?? json['name'])?.toString() ?? '',
      school: json['school']?.toString() ?? '',
      pickupAddress: json['pickup_address']?.toString() ?? '',
      dropoffAddress: json['dropoff_address']?.toString() ?? '',
      pickupTime: json['pickup_time']?.toString(),
      dropoffTime: json['dropoff_time']?.toString(),
      scannedPickupAt: json['scanned_pickup_at']?.toString(),
      scannedDropoffAt: json['scanned_dropoff_at']?.toString(),
      status: json['status']?.toString() ?? '',
      pickupStatus: json['pickup_status']?.toString() ?? '',
      dropoffStatus: json['dropoff_status']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
        childId,
        childName,
        school,
        pickupAddress,
        dropoffAddress,
        pickupTime,
        dropoffTime,
        scannedPickupAt,
        scannedDropoffAt,
        status,
        pickupStatus,
        dropoffStatus,
      ];
}

/// تفاصيل رحلة من السجل (GET /driver/trips/history/{tripId})
class DriverTripHistoryDetailsModel extends Equatable {
  final int tripId;
  final String tripDate;
  final String routeName;
  final String status;
  final int duration;
  final List<TripHistoryChildModel> children;

  const DriverTripHistoryDetailsModel({
    required this.tripId,
    required this.tripDate,
    required this.routeName,
    required this.status,
    required this.duration,
    required this.children,
  });

  factory DriverTripHistoryDetailsModel.fromJson(Map<String, dynamic> json) {
    return DriverTripHistoryDetailsModel(
      tripId: DriverTripHistoryModel._parseInt(json['trip_id']),
      tripDate: json['trip_date']?.toString() ?? '',
      routeName: json['route_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      duration: DriverTripHistoryModel._parseInt(json['duration']),
      children: json['children'] is List
          ? (json['children'] as List)
              .whereType<Map>()
              .map((e) => TripHistoryChildModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  @override
  List<Object?> get props => [tripId, tripDate, routeName, status, duration, children];
}
