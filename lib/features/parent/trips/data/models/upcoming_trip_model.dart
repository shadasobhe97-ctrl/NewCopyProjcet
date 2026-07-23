class UpcomingTripModel {
  final String childName;
  final String tripType;
  final String title;
  final String scheduledFor;
  final String driverName;
  final String schoolName;

  const UpcomingTripModel({
    required this.childName,
    required this.tripType,
    required this.title,
    required this.scheduledFor,
    required this.driverName,
    required this.schoolName,
  });

  factory UpcomingTripModel.fromJson(Map<String, dynamic> json) {
    return UpcomingTripModel(
      childName: json['child_name']?.toString() ?? '',
      tripType: json['trip_type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      scheduledFor: json['scheduled_for']?.toString() ?? '',
      driverName: json['driver_name']?.toString() ?? '',
      schoolName: json['school_name']?.toString() ?? '',
    );
  }
}
