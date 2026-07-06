class TransportPrefModel {
  final String subscriptionType; // monthly, weekly, days
  final String period; // morning, evening
  final String serviceType; // go, return, both
  final DateTime startDate;
  final DateTime? endDate;
  final String schoolStartTime; // e.g., "08:00 AM"
  final String schoolEndTime; // e.g., "01:30 PM"

  TransportPrefModel({
    required this.subscriptionType,
    required this.period,
    required this.serviceType,
    required this.startDate,
    this.endDate,
    required this.schoolStartTime,
    required this.schoolEndTime,
  });

  factory TransportPrefModel.fromJson(Map<String, dynamic> json) {
    return TransportPrefModel(
      subscriptionType: json['subscription_type'],
      period: json['period'],
      serviceType: json['service_type'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      schoolStartTime: json['school_start_time'],
      schoolEndTime: json['school_end_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscription_type': subscriptionType,
      'period': period,
      'service_type': serviceType,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'school_start_time': schoolStartTime,
      'school_end_time': schoolEndTime,
    };
  }
}