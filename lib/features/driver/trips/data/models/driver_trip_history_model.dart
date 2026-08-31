import 'package:equatable/equatable.dart';

/// كائن الترقيم في استجابة سجل الرحلات
class PaginationModel extends Equatable {
  final int currentPage;
  final int totalPages;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  const PaginationModel({
    required this.currentPage,
    required this.totalPages,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMore,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    final currentPage = parseInt(json['current_page'] ?? json['currentPage'] ?? 1);
    final totalPages = parseInt(json['total_pages'] ?? json['last_page'] ?? 1);
    final lastPage = parseInt(json['last_page'] ?? json['total_pages'] ?? 1);
    final perPage = parseInt(json['per_page'] ?? 15);
    final total = parseInt(json['total'] ?? 0);
    final hasMore = json['has_more'] is bool
        ? json['has_more'] as bool
        : (currentPage < lastPage);

    return PaginationModel(
      currentPage: currentPage,
      totalPages: totalPages,
      lastPage: lastPage,
      perPage: perPage,
      total: total,
      hasMore: hasMore,
    );
  }

  factory PaginationModel.empty() => const PaginationModel(
        currentPage: 1,
        totalPages: 1,
        lastPage: 1,
        perPage: 15,
        total: 0,
        hasMore: false,
      );

  @override
  List<Object?> get props => [currentPage, totalPages, lastPage, perPage, total, hasMore];
}

/// غلاف استجابة سجل رحلات السائق الكامل (GET /api/v1/driver/trips/history)
class DriverTripHistoryResponseModel extends Equatable {
  final String status;
  final List<DriverTripHistoryModel> data;
  final PaginationModel pagination;

  const DriverTripHistoryResponseModel({
    required this.status,
    required this.data,
    required this.pagination,
  });

  factory DriverTripHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final tripsList = (rawList is List)
        ? rawList
            .whereType<Map>()
            .map((e) => DriverTripHistoryModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <DriverTripHistoryModel>[];

    final paginationMap = json['pagination'] is Map
        ? Map<String, dynamic>.from(json['pagination'] as Map)
        : null;

    return DriverTripHistoryResponseModel(
      status: json['status']?.toString() ?? 'success',
      data: tripsList,
      pagination: paginationMap != null
          ? PaginationModel.fromJson(paginationMap)
          : PaginationModel.empty(),
    );
  }

  @override
  List<Object?> get props => [status, data, pagination];
}

/// عنصر في سجل الرحلات (GET /driver/trips/history)
class DriverTripHistoryModel extends Equatable {
  final int tripId;
  final String tripDate;
  final String routeName;
  final String status;
  final int duration;

  const DriverTripHistoryModel({
    required this.tripId,
    required this.tripDate,
    required this.routeName,
    required this.status,
    required this.duration,
  });

  factory DriverTripHistoryModel.fromJson(Map<String, dynamic> json) {
    return DriverTripHistoryModel(
      tripId: _parseInt(json['trip_id']),
      tripDate: json['trip_date']?.toString() ?? '',
      routeName: json['route_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      duration: _parseInt(json['duration']),
    );
  }

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  @override
  List<Object?> get props => [tripId, tripDate, routeName, status, duration];
}

/// ملخص إحصائيات الرحلة السابقة
class TripHistorySummaryModel extends Equatable {
  final int totalStudents;
  final int pickedUp;
  final int absent;

  const TripHistorySummaryModel({
    required this.totalStudents,
    required this.pickedUp,
    required this.absent,
  });

  factory TripHistorySummaryModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return TripHistorySummaryModel(
      totalStudents: parseInt(json['total_students'] ?? json['total']),
      pickedUp: parseInt(json['picked_up']),
      absent: parseInt(json['absent']),
    );
  }

  factory TripHistorySummaryModel.empty() => const TripHistorySummaryModel(
        totalStudents: 0,
        pickedUp: 0,
        absent: 0,
      );

  @override
  List<Object?> get props => [totalStudents, pickedUp, absent];
}

/// طفل ضمن تفاصيل رحلة من السجل — عنصر موحّد واحد لكل طفل
class TripHistoryChildModel extends Equatable {
  final int childId;
  final String childName;
  final String school;
  final String schoolName;
  final String pickupAddress;
  final String dropoffAddress;
  final String? pickupTime;
  final String? dropoffTime;
  final String? scannedPickupAt;
  final String? scannedDropoffAt;
  final String status;
  final String? reason;
  final String pickupStatus;
  final String dropoffStatus;
  final String? actionType;
  final String? scannedAt;

  const TripHistoryChildModel({
    required this.childId,
    required this.childName,
    required this.school,
    required this.schoolName,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupTime,
    required this.dropoffTime,
    required this.scannedPickupAt,
    required this.scannedDropoffAt,
    required this.status,
    required this.reason,
    required this.pickupStatus,
    required this.dropoffStatus,
    required this.actionType,
    required this.scannedAt,
  });

  factory TripHistoryChildModel.fromJson(Map<String, dynamic> json) {
    return TripHistoryChildModel(
      childId: DriverTripHistoryModel._parseInt(json['child_id']),
      childName: (json['child_name'] ?? json['name'])?.toString() ?? '',
      school: json['school']?.toString() ?? json['school_name']?.toString() ?? '',
      schoolName: json['school_name']?.toString() ?? json['school']?.toString() ?? '',
      pickupAddress: json['pickup_address']?.toString() ?? '',
      dropoffAddress: json['dropoff_address']?.toString() ?? '',
      pickupTime: json['pickup_time']?.toString(),
      dropoffTime: json['dropoff_time']?.toString(),
      scannedPickupAt: json['scanned_pickup_at']?.toString(),
      scannedDropoffAt: json['scanned_dropoff_at']?.toString(),
      status: json['status']?.toString() ?? '',
      reason: json['reason']?.toString(),
      pickupStatus: json['pickup_status']?.toString() ?? '',
      dropoffStatus: json['dropoff_status']?.toString() ?? '',
      actionType: json['action_type']?.toString(),
      scannedAt: json['scanned_at']?.toString(),
    );
  }

  bool get isSkipped => status == 'skipped' || actionType == 'skipped' || pickupStatus == 'skipped';
  bool get isAbsent => status == 'absent' || actionType == 'absent' || pickupStatus == 'absent';
  bool get isCompleted => status == 'completed' || actionType == 'dropped_off';

  @override
  List<Object?> get props => [
        childId,
        childName,
        school,
        schoolName,
        pickupAddress,
        dropoffAddress,
        pickupTime,
        dropoffTime,
        scannedPickupAt,
        scannedDropoffAt,
        status,
        reason,
        pickupStatus,
        dropoffStatus,
        actionType,
        scannedAt,
      ];
}

/// تفاصيل رحلة من السجل (GET /driver/trips/history/{tripId})
class DriverTripHistoryDetailsModel extends Equatable {
  final int tripId;
  final String tripDate;
  final String routeName;
  final String status;
  final String? actualStartedAt;
  final String? actualCompletedAt;
  final int duration;
  final double distance;
  final TripHistorySummaryModel summary;
  final List<TripHistoryChildModel> children;

  const DriverTripHistoryDetailsModel({
    required this.tripId,
    required this.tripDate,
    required this.routeName,
    required this.status,
    this.actualStartedAt,
    this.actualCompletedAt,
    required this.duration,
    required this.distance,
    required this.summary,
    required this.children,
  });

  factory DriverTripHistoryDetailsModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val is double) return val;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return DriverTripHistoryDetailsModel(
      tripId: DriverTripHistoryModel._parseInt(json['trip_id']),
      tripDate: json['trip_date']?.toString() ?? '',
      routeName: json['route_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      actualStartedAt: json['actual_started_at']?.toString(),
      actualCompletedAt: json['actual_completed_at']?.toString(),
      duration: DriverTripHistoryModel._parseInt(json['duration']),
      distance: parseDouble(json['distance']),
      summary: json['summary'] is Map
          ? TripHistorySummaryModel.fromJson(Map<String, dynamic>.from(json['summary'] as Map))
          : TripHistorySummaryModel.empty(),
      children: json['children'] is List
          ? (json['children'] as List)
              .whereType<Map>()
              .map((e) => TripHistoryChildModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  @override
  List<Object?> get props => [
        tripId,
        tripDate,
        routeName,
        status,
        actualStartedAt,
        actualCompletedAt,
        duration,
        distance,
        summary,
        children,
      ];
}
