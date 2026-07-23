class TripTrackModel {
  final int tripId;
  final String status;
  final double driverLat;
  final double driverLng;
  final String lastUpdated;

  const TripTrackModel({
    required this.tripId,
    required this.status,
    required this.driverLat,
    required this.driverLng,
    required this.lastUpdated,
  });

  factory TripTrackModel.fromJson(Map<String, dynamic> json) {
    return TripTrackModel(
      tripId: json['trip_id'] as int? ?? 0,
      status: json['status']?.toString() ?? '',
      driverLat: (json['driver_lat'] as num?)?.toDouble() ?? 0.0,
      driverLng: (json['driver_lng'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: json['last_updated']?.toString() ?? '',
    );
  }
}
