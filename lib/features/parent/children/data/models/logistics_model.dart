class LogisticsModel {
  final String preferredTimeSlot; // morning, evening
  final String tripDirection; // go, return, both
  final String? pickupTime;
  final String? dropoffTime;
  final DateTime startDate;
  final DateTime? endDate;
  final String subscriptionType; // monthly, weekly, days

  LogisticsModel({
    required this.preferredTimeSlot,
    required this.tripDirection,
    this.pickupTime,
    this.dropoffTime,
    required this.startDate,
    this.endDate,
    required this.subscriptionType,
  });

  factory LogisticsModel.fromJson(Map<String, dynamic> json) {
    return LogisticsModel(
      preferredTimeSlot: json['preferred_time_slot'] as String? ?? 'morning',
      tripDirection: json['trip_direction'] as String? ?? 'both',
      pickupTime: json['pickup_time'] as String?,
      dropoffTime: json['dropoff_time'] as String?,
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ?? DateTime.now(),
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date'] as String) : null,
      subscriptionType: json['subscription_type'] as String? ?? 'monthly',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferred_time_slot': preferredTimeSlot,
      'trip_direction': tripDirection,
      if (pickupTime != null) 'pickup_time': pickupTime,
      if (dropoffTime != null) 'dropoff_time': dropoffTime,
      'start_date': startDate.toIso8601String().split('T').first,
      if (endDate != null) 'end_date': endDate!.toIso8601String().split('T').first,
      'subscription_type': subscriptionType,
    };
  }
}
