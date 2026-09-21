class AvailableTripModel {
  final int tripId;
  final String direction;
  final String? shiftSlot;
  final int driverId;
  final String driverName;

  AvailableTripModel({
    required this.tripId,
    required this.direction,
    this.shiftSlot,
    required this.driverId,
    required this.driverName,
  });

  factory AvailableTripModel.fromJson(Map<String, dynamic> json) {
    return AvailableTripModel(
      tripId: int.tryParse(json['trip_id']?.toString() ?? '') ?? 0,
      direction: json['direction']?.toString() ?? 'to_school',
      shiftSlot: json['shift_slot']?.toString(),
      driverId: int.tryParse(json['driver_id']?.toString() ?? '') ?? 0,
      driverName: json['driver_name']?.toString() ?? json['driver']?['name']?.toString() ?? 'سائق',
    );
  }
}

class ChildAvailableTripsModel {
  final int childId;
  final String childName;
  final List<AvailableTripModel> availableTrips;

  ChildAvailableTripsModel({
    required this.childId,
    required this.childName,
    required this.availableTrips,
  });

  factory ChildAvailableTripsModel.fromJson(Map<String, dynamic> json) {
    final tripsList = (json['available_trips'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => AvailableTripModel.fromJson(e))
        .toList();

    return ChildAvailableTripsModel(
      childId: int.tryParse(json['child_id']?.toString() ?? '') ?? 0,
      childName: json['child_name']?.toString() ?? 'طفل',
      availableTrips: tripsList,
    );
  }
}
