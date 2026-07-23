class ActiveTripModel {
  final int tripId;
  final String tripType;
  final String status;
  final String driverName;
  final String driverPhone;
  final String vehicleInfo;
  final int childId;
  final String childName;
  final String childStatus;
  final String? waitingTimer;
  final String startedAt;

  const ActiveTripModel({
    required this.tripId,
    required this.tripType,
    required this.status,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleInfo,
    required this.childId,
    required this.childName,
    required this.childStatus,
    this.waitingTimer,
    required this.startedAt,
  });

  factory ActiveTripModel.fromJson(Map<String, dynamic> json) {
    return ActiveTripModel(
      tripId: json['trip_id'] as int? ?? 0,
      tripType: json['trip_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      driverName: json['driver_name']?.toString() ?? '',
      driverPhone: json['driver_phone']?.toString() ?? '',
      vehicleInfo: json['vehicle_info']?.toString() ?? '',
      childId: json['child_id'] as int? ?? 0,
      childName: json['child_name']?.toString() ?? '',
      childStatus: json['child_status']?.toString() ?? '',
      waitingTimer: json['waiting_timer']?.toString(),
      startedAt: json['started_at']?.toString() ?? '',
    );
  }
}
