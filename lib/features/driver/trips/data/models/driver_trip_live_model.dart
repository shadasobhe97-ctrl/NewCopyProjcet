import 'package:equatable/equatable.dart';

/// الطفل الحالي ضمن شاشة البث المباشر (GET /driver/trips/{tripId}/live)
class TripLiveCurrentChildModel extends Equatable {
  final int tripChildId;
  final int childId;
  final String name;
  final String school;
  final String pickupAddress;
  final double latitude;
  final double longitude;
  final String status;
  final String pickupStatus;
  final String dropoffStatus;
  final String? eta;

  const TripLiveCurrentChildModel({
    required this.tripChildId,
    required this.childId,
    required this.name,
    required this.school,
    required this.pickupAddress,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.pickupStatus,
    required this.dropoffStatus,
    required this.eta,
  });

  factory TripLiveCurrentChildModel.fromJson(Map<String, dynamic> json) {
    return TripLiveCurrentChildModel(
      tripChildId: _parseInt(json['trip_child_id']),
      childId: _parseInt(json['child_id']),
      name: json['name']?.toString() ?? '',
      school: json['school']?.toString() ?? '',
      pickupAddress: json['pickup_address']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      status: json['status']?.toString() ?? 'pending',
      pickupStatus: json['pickup_status']?.toString() ?? 'pending',
      dropoffStatus: json['dropoff_status']?.toString() ?? 'pending',
      eta: json['eta']?.toString(),
    );
  }

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic val) {
    if (val is double) return val;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  @override
  List<Object?> get props => [
        tripChildId,
        childId,
        name,
        school,
        pickupAddress,
        latitude,
        longitude,
        status,
        pickupStatus,
        dropoffStatus,
        eta,
      ];
}

class TripProgressModel extends Equatable {
  final int total;
  final int completed;
  final int remaining;

  const TripProgressModel({
    required this.total,
    required this.completed,
    required this.remaining,
  });

  factory TripProgressModel.fromJson(Map<String, dynamic> json) {
    return TripProgressModel(
      total: TripLiveCurrentChildModel._parseInt(json['total']),
      completed: TripLiveCurrentChildModel._parseInt(json['completed']),
      remaining: TripLiveCurrentChildModel._parseInt(json['remaining']),
    );
  }

  factory TripProgressModel.empty() =>
      const TripProgressModel(total: 0, completed: 0, remaining: 0);

  @override
  List<Object?> get props => [total, completed, remaining];
}

class DriverTripLiveModel extends Equatable {
  final String tripStatus;
  final TripLiveCurrentChildModel? currentChild;
  final TripProgressModel progress;

  const DriverTripLiveModel({
    required this.tripStatus,
    required this.currentChild,
    required this.progress,
  });

  factory DriverTripLiveModel.fromJson(Map<String, dynamic> json) {
    return DriverTripLiveModel(
      tripStatus: json['trip_status']?.toString() ?? 'pending',
      currentChild: json['current_child'] is Map
          ? TripLiveCurrentChildModel.fromJson(
              Map<String, dynamic>.from(json['current_child'] as Map))
          : null,
      progress: json['progress'] is Map
          ? TripProgressModel.fromJson(Map<String, dynamic>.from(json['progress'] as Map))
          : TripProgressModel.empty(),
    );
  }

  bool get isInProgress => tripStatus == 'in_progress';
  bool get isSuspended => tripStatus == 'suspended_breakdown';
  bool get isCompleted => tripStatus == 'completed';

  @override
  List<Object?> get props => [tripStatus, currentChild, progress];
}
