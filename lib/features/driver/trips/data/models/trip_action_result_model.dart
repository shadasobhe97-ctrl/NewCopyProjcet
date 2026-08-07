import 'package:equatable/equatable.dart';

/// نتيجة بدء الرحلة (POST /driver/trips/{tripId}/start)
class TripStartResultModel extends Equatable {
  final int tripId;
  final String status;
  final String? startedAt;

  const TripStartResultModel({
    required this.tripId,
    required this.status,
    required this.startedAt,
  });

  factory TripStartResultModel.fromJson(Map<String, dynamic> json) {
    return TripStartResultModel(
      tripId: _parseInt(json['trip_id']),
      status: json['status']?.toString() ?? 'in_progress',
      startedAt: json['started_at']?.toString(),
    );
  }

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  @override
  List<Object?> get props => [tripId, status, startedAt];
}

/// ملخص إنهاء الرحلة (POST /driver/trips/{tripId}/complete)
class TripCompleteSummaryModel extends Equatable {
  final int children;
  final int pickedUp;
  final int droppedOff;
  final int absent;
  final int duration;
  final double distance;

  const TripCompleteSummaryModel({
    required this.children,
    required this.pickedUp,
    required this.droppedOff,
    required this.absent,
    required this.duration,
    required this.distance,
  });

  factory TripCompleteSummaryModel.fromJson(Map<String, dynamic> json) {
    return TripCompleteSummaryModel(
      children: TripStartResultModel._parseInt(json['children']),
      pickedUp: TripStartResultModel._parseInt(json['picked_up']),
      droppedOff: TripStartResultModel._parseInt(json['dropped_off']),
      absent: TripStartResultModel._parseInt(json['absent']),
      duration: TripStartResultModel._parseInt(json['duration']),
      distance: _parseDouble(json['distance']),
    );
  }

  static double _parseDouble(dynamic val) {
    if (val is double) return val;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  @override
  List<Object?> get props => [children, pickedUp, droppedOff, absent, duration, distance];
}

/// الطفل التالي المُرجع من نقطة تحديث الحالة
class NextChildModel extends Equatable {
  final int tripChildId;
  final String name;

  const NextChildModel({required this.tripChildId, required this.name});

  factory NextChildModel.fromJson(Map<String, dynamic> json) {
    return NextChildModel(
      tripChildId: TripStartResultModel._parseInt(json['trip_child_id']),
      name: json['name']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [tripChildId, name];
}

/// نتيجة تحديث حالة طفل (صعود/نزول/غياب/تجاوز/QR...)
class ChildStatusActionResultModel extends Equatable {
  final String message;
  final NextChildModel? nextChild;

  const ChildStatusActionResultModel({required this.message, required this.nextChild});

  factory ChildStatusActionResultModel.fromJson(Map<String, dynamic> json) {
    return ChildStatusActionResultModel(
      message: json['message']?.toString() ?? '',
      nextChild: json['next_child'] is Map
          ? NextChildModel.fromJson(Map<String, dynamic>.from(json['next_child'] as Map))
          : null,
    );
  }

  @override
  List<Object?> get props => [message, nextChild];
}

/// نتيجة تغيير حالة الرحلة (عطل / استئناف)
class TripStatusChangeResultModel extends Equatable {
  final int tripId;
  final String status;

  const TripStatusChangeResultModel({required this.tripId, required this.status});

  factory TripStatusChangeResultModel.fromJson(Map<String, dynamic> json) {
    return TripStatusChangeResultModel(
      tripId: TripStartResultModel._parseInt(json['trip_id']),
      status: json['status']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [tripId, status];
}
