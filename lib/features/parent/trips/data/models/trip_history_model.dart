class TripHistoryModel {
  final int tripId;
  final String tripType;
  final String tripDate;
  final String childName;
  final String driverName;
  final String actionType;
  final String scannedAt;
  final String tripCost;

  const TripHistoryModel({
    required this.tripId,
    required this.tripType,
    required this.tripDate,
    required this.childName,
    required this.driverName,
    required this.actionType,
    required this.scannedAt,
    required this.tripCost,
  });

  factory TripHistoryModel.fromJson(Map<String, dynamic> json) {
    return TripHistoryModel(
      tripId: json['trip_id'] as int? ?? 0,
      tripType: json['trip_type']?.toString() ?? '',
      tripDate: json['trip_date']?.toString() ?? '',
      childName: json['child_name']?.toString() ?? '',
      driverName: json['driver_name']?.toString() ?? '',
      actionType: json['action_type']?.toString() ?? '',
      scannedAt: json['scanned_at']?.toString() ?? '',
      tripCost: json['trip_cost']?.toString() ?? '0.00',
    );
  }
}
