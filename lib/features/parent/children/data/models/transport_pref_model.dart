import 'logistics_model.dart';

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
      subscriptionType: json['subscription_type'] ?? 'monthly',
      period: json['period'] ?? 'morning',
      serviceType: json['service_type'] ?? 'both',
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ?? DateTime.now(),
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date'] as String) : null,
      schoolStartTime: json['school_start_time'] ?? '08:00 AM',
      schoolEndTime: json['school_end_time'] ?? '01:30 PM',
    );
  }

  factory TransportPrefModel.fromLogistics(LogisticsModel logistics) {
    return TransportPrefModel(
      subscriptionType: logistics.subscriptionType,
      period: logistics.preferredTimeSlot,
      serviceType: logistics.tripDirection,
      startDate: logistics.startDate,
      endDate: logistics.endDate,
      schoolStartTime: logistics.pickupTime ?? '08:00 AM',
      schoolEndTime: logistics.dropoffTime ?? '01:30 PM',
    );
  }

  LogisticsModel toLogistics() {
    return LogisticsModel(
      preferredTimeSlot: period,
      tripDirection: serviceType,
      pickupTime: schoolStartTime,
      dropoffTime: schoolEndTime,
      startDate: startDate,
      endDate: endDate,
      subscriptionType: subscriptionType,
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