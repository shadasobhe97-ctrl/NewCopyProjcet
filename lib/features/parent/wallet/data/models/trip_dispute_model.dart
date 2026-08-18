class TripDisputeModel {
  final int id;
  final int tripId;
  final int parentId;
  final int? driverId;
  final String reason;
  final String status;
  final String? createdAt;

  TripDisputeModel({
    required this.id,
    required this.tripId,
    required this.parentId,
    this.driverId,
    required this.reason,
    required this.status,
    this.createdAt,
  });

  factory TripDisputeModel.fromJson(Map<String, dynamic> json) {
    return TripDisputeModel(
      id: json['id'] ?? 0,
      tripId: json['trip_id'] ?? 0,
      parentId: json['parent_id'] ?? 0,
      driverId: json['driver_id'],
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      createdAt: json['created_at']?.toString(),
    );
  }
}
