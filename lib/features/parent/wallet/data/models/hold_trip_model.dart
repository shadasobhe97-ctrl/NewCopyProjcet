class HoldTripModel {
  final int id;
  final int tripId;
  final int parentId;
  final int? driverId;
  final double amount;
  final String holdStatus;
  final String? heldAt;

  HoldTripModel({
    required this.id,
    required this.tripId,
    required this.parentId,
    this.driverId,
    required this.amount,
    required this.holdStatus,
    this.heldAt,
  });

  factory HoldTripModel.fromJson(Map<String, dynamic> json) {
    return HoldTripModel(
      id: json['id'] ?? 0,
      tripId: json['trip_id'] ?? 0,
      parentId: json['parent_id'] ?? 0,
      driverId: json['driver_id'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      holdStatus: json['hold_status']?.toString() ?? 'held',
      heldAt: json['held_at']?.toString(),
    );
  }
}
