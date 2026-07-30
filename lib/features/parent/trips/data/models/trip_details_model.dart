import 'active_trip_model.dart';
import 'trip_timeline_model.dart';

class TripDetailsModel {
  final int tripId;
  final String tripType;
  final String direction;
  final String status;
  final String startedAt;
  final String? endedAt;
  final DriverInfo driver;
  final VehicleInfoModel vehicle;
  final DestinationInfo destination;
  final List<TripChildInfo> children;
  final List<TripTimelineItemModel> timeline;
  final String? totalDistance;
  final String? estimatedDuration;

  const TripDetailsModel({
    required this.tripId,
    required this.tripType,
    required this.direction,
    required this.status,
    required this.startedAt,
    this.endedAt,
    required this.driver,
    required this.vehicle,
    required this.destination,
    required this.children,
    required this.timeline,
    this.totalDistance,
    this.estimatedDuration,
  });

  factory TripDetailsModel.fromJson(Map<String, dynamic> json) {
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
    DestinationInfo destObj = DestinationInfo.fromJson(json['destination'] is Map<String, dynamic> ? json['destination'] : {});

    List<TripChildInfo> childrenList = [];
    if (json['children'] is List) {
      childrenList = (json['children'] as List)
          .map((e) => TripChildInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<TripTimelineItemModel> timelineList = [];
    if (json['timeline'] is List) {
      timelineList = (json['timeline'] as List)
          .map((e) => TripTimelineItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return TripDetailsModel(
      tripId: json['trip_id'] as int? ?? json['id'] as int? ?? 0,
      tripType: json['trip_type']?.toString() ?? 'morning',
      direction: json['direction']?.toString() ?? 'to_school',
      status: json['status']?.toString() ?? 'active',
      startedAt: json['started_at']?.toString() ?? '',
      endedAt: json['ended_at']?.toString(),
      driver: driverObj,
      vehicle: vehicleObj,
      destination: destObj,
      children: childrenList,
      timeline: timelineList,
      totalDistance: json['total_distance']?.toString() ?? '12.4 كم',
      estimatedDuration: json['estimated_duration']?.toString() ?? '25 دقيقة',
    );
  }
}
