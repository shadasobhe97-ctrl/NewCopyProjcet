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

/// المحطة التالية المرجعة من نقطة تحديث حالة الطفل (next_stop)
class NextStopModel extends Equatable {
  final int stopId;
  final String stopType; // home | school
  final int sequenceOrder;
  final String? name;
  final String? title;
  final int? childId;
  final int? tripChildId;
  final String? childName;
  final int? schoolId;
  final String? schoolName;
  final double latitude;
  final double longitude;
  final double? lat;
  final double? lng;
  final String? address;
  final String status;
  final String? eta;

  const NextStopModel({
    required this.stopId,
    required this.stopType,
    required this.sequenceOrder,
    this.name,
    this.title,
    this.childId,
    this.tripChildId,
    this.childName,
    this.schoolId,
    this.schoolName,
    required this.latitude,
    required this.longitude,
    this.lat,
    this.lng,
    this.address,
    required this.status,
    this.eta,
  });

  factory NextStopModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double parseDouble(dynamic val) {
      if (val is double) return val;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    final latVal = json['latitude'] ?? json['lat'];
    final lngVal = json['longitude'] ?? json['lng'];

    return NextStopModel(
      stopId: parseInt(json['stop_id'] ?? json['id']),
      stopType: json['stop_type']?.toString() ?? 'home',
      sequenceOrder: parseInt(json['sequence_order']),
      name: json['name']?.toString(),
      title: json['title']?.toString(),
      childId: json['child_id'] == null ? null : parseInt(json['child_id']),
      tripChildId: json['trip_child_id'] == null ? null : parseInt(json['trip_child_id']),
      childName: json['child_name']?.toString() ?? json['name']?.toString(),
      schoolId: json['school_id'] == null ? null : parseInt(json['school_id']),
      schoolName: json['school_name']?.toString(),
      latitude: parseDouble(latVal),
      longitude: parseDouble(lngVal),
      lat: json['lat'] != null ? parseDouble(json['lat']) : null,
      lng: json['lng'] != null ? parseDouble(json['lng']) : null,
      address: json['address']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      eta: json['eta']?.toString(),
    );
  }

  bool get isHome => stopType == 'home';
  bool get isSchool => stopType == 'school';

  @override
  List<Object?> get props => [
        stopId,
        stopType,
        sequenceOrder,
        name,
        title,
        childId,
        tripChildId,
        childName,
        schoolId,
        schoolName,
        latitude,
        longitude,
        lat,
        lng,
        address,
        status,
        eta,
      ];
}

/// نتيجة تحديث حالة طفل (صعود/نزول/غياب/تعذر تسليم/تسليم مباشر/QR...)
class ChildStatusActionResultModel extends Equatable {
  final String status;
  final String message;
  final NextStopModel? nextStop;
  final NextChildModel? nextChild;

  const ChildStatusActionResultModel({
    required this.status,
    required this.message,
    this.nextStop,
    this.nextChild,
  });

  factory ChildStatusActionResultModel.fromJson(Map<String, dynamic> json) {
    NextStopModel? parsedNextStop;
    if (json['next_stop'] is Map) {
      parsedNextStop = NextStopModel.fromJson(
        Map<String, dynamic>.from(json['next_stop'] as Map),
      );
    }

    NextChildModel? parsedNextChild;
    if (json['next_child'] is Map) {
      parsedNextChild = NextChildModel.fromJson(
        Map<String, dynamic>.from(json['next_child'] as Map),
      );
    } else if (parsedNextStop != null && parsedNextStop.tripChildId != null) {
      parsedNextChild = NextChildModel(
        tripChildId: parsedNextStop.tripChildId!,
        name: parsedNextStop.childName ?? parsedNextStop.name ?? '',
      );
    }

    return ChildStatusActionResultModel(
      status: json['status']?.toString() ?? 'success',
      message: json['message']?.toString() ?? '',
      nextStop: parsedNextStop,
      nextChild: parsedNextChild,
    );
  }

  @override
  List<Object?> get props => [status, message, nextStop, nextChild];
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
