import 'active_trip_model.dart';

class UpcomingTripModel {
  final int tripId;
  final String tripType;
  final String direction;
  final String scheduledDate;
  final String scheduledTime;
  final DriverInfo driver;
  final VehicleInfoModel vehicle;
  final List<TripChildInfo> children;
  final DestinationInfo destination;

  const UpcomingTripModel({
    required this.tripId,
    required this.tripType,
    required this.direction,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.driver,
    required this.vehicle,
    required this.children,
    required this.destination,
  });

  // Legacy getters
  String get childName => children.isNotEmpty ? children.first.childName : '';
  String get driverName => driver.name;
  String get schoolName => destination.name;
  String get title => direction == 'to_home' ? 'رحلة العودة' : 'رحلة الذهاب';
  String get scheduledFor => '$scheduledDate $scheduledTime'.trim();

  factory UpcomingTripModel.fromJson(Map<String, dynamic> json) {
    DriverInfo driverObj;
    if (json['driver'] is Map<String, dynamic>) {
      driverObj = DriverInfo.fromJson(json['driver'] as Map<String, dynamic>);
    } else {
      driverObj = DriverInfo(
        id: json['driver_id'] as int? ?? 0,
        name: json['driver_name']?.toString() ?? '',
        phone: json['driver_phone']?.toString() ?? '',
        photo: json['driver_photo']?.toString(),
      );
    }

    VehicleInfoModel vehicleObj = VehicleInfoModel.fromJson(json['vehicle'] ?? json['vehicle_info']);

    List<TripChildInfo> childrenList = [];
    if (json['children'] is List) {
      childrenList = (json['children'] as List)
          .map((e) => TripChildInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['child_name'] != null) {
      childrenList = [
        TripChildInfo(
          childId: json['child_id'] as int? ?? 0,
          childName: json['child_name']?.toString() ?? '',
          childPhoto: json['child_photo']?.toString(),
          childStatus: 'scheduled',
        )
      ];
    }

    DestinationInfo destObj;
    if (json['destination'] is Map<String, dynamic>) {
      destObj = DestinationInfo.fromJson(json['destination'] as Map<String, dynamic>);
    } else {
      destObj = DestinationInfo(
        name: json['school_name']?.toString() ?? json['destination_name']?.toString() ?? 'المدرسة',
        type: 'school',
        lat: 32.8872,
        lng: 13.1913,
      );
    }

    return UpcomingTripModel(
      tripId: json['trip_id'] as int? ?? json['id'] as int? ?? 0,
      tripType: json['trip_type']?.toString() ?? 'morning',
      direction: json['direction']?.toString() ?? (json['trip_type'] == 'evening' ? 'to_home' : 'to_school'),
      scheduledDate: json['scheduled_date']?.toString() ?? json['scheduled_for']?.toString() ?? '',
      scheduledTime: json['scheduled_time']?.toString() ?? '',
      driver: driverObj,
      vehicle: vehicleObj,
      children: childrenList,
      destination: destObj,
    );
  }
}
