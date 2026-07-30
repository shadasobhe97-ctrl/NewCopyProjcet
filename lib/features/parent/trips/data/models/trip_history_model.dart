import 'active_trip_model.dart';

class TripHistoryModel {
  final int tripId;
  final String tripType;
  final String direction;
  final String tripDate;
  final List<TripChildInfo> children;
  final String driverName;
  final String pickupTime;
  final String dropoffTime;
  final String tripCost;
  final String status;

  const TripHistoryModel({
    required this.tripId,
    required this.tripType,
    required this.direction,
    required this.tripDate,
    required this.children,
    required this.driverName,
    required this.pickupTime,
    required this.dropoffTime,
    required this.tripCost,
    required this.status,
  });

  // Backward compatibility getters
  String get childName => children.isNotEmpty ? children.first.childName : '';
  String get actionType => status == 'completed' ? 'وصل بنجاح' : (status == 'absent' ? 'غياب' : 'رحلة مكتملة');
  String get scannedAt => pickupTime.isNotEmpty ? pickupTime : dropoffTime;

  factory TripHistoryModel.fromJson(Map<String, dynamic> json) {
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
          childStatus: json['status']?.toString() ?? 'arrived',
        )
      ];
    }

    return TripHistoryModel(
      tripId: json['trip_id'] as int? ?? json['id'] as int? ?? 0,
      tripType: json['trip_type']?.toString() ?? 'morning',
      direction: json['direction']?.toString() ?? (json['trip_type'] == 'evening' ? 'to_home' : 'to_school'),
      tripDate: json['trip_date']?.toString() ?? '',
      children: childrenList,
      driverName: json['driver_name']?.toString() ?? json['driver']?['name']?.toString() ?? 'السائق',
      pickupTime: json['pickup_time']?.toString() ?? json['started_at']?.toString() ?? '',
      dropoffTime: json['dropoff_time']?.toString() ?? json['scanned_at']?.toString() ?? '',
      tripCost: json['trip_cost']?.toString() ?? '0.00 د.ل',
      status: json['status']?.toString() ?? 'completed',
    );
  }
}
