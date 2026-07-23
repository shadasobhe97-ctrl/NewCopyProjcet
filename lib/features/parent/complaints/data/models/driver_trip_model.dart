class DriverTripModel {
  final int id;
  final String title;
  final String? tripType;
  final String? status;
  final String? scheduledFor;

  DriverTripModel({
    required this.id,
    required this.title,
    this.tripType,
    this.status,
    this.scheduledFor,
  });

  factory DriverTripModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['trip_id'] ?? 0;
    final idVal = rawId is num ? rawId.toInt() : int.tryParse(rawId.toString()) ?? 0;

    final typeVal = json['trip_type'] ?? json['type'] ?? json['timing'];
    final dateVal = json['scheduled_for'] ?? json['created_at'] ?? json['start_date'];
    
    // Title generation
    String generatedTitle = json['title'] ?? json['name'] ?? '';
    if (generatedTitle.isEmpty) {
      if (typeVal != null && typeVal.toString().isNotEmpty) {
        final timingAr = typeVal.toString().toUpperCase() == 'MORNING' ? 'صباحية' : 'مسائية';
        generatedTitle = 'رحلة $timingAr (#$idVal)';
      } else {
        generatedTitle = 'رحلة #$idVal';
      }
    }

    return DriverTripModel(
      id: idVal,
      title: generatedTitle,
      tripType: typeVal?.toString(),
      status: json['status']?.toString(),
      scheduledFor: dateVal?.toString(),
    );
  }
}
