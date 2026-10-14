import 'package:equatable/equatable.dart';

/// بيانات طفل منقول من حافلة متعطلة (ضمن محطة الإنقاذ)
class TransferredChildModel extends Equatable {
  final int id;
  final int childId;
  final String name;
  final int? schoolId;
  final String? schoolName;

  const TransferredChildModel({
    required this.id,
    required this.childId,
    required this.name,
    this.schoolId,
    this.schoolName,
  });

  factory TransferredChildModel.fromJson(Map<String, dynamic> json) {
    return TransferredChildModel(
      id: DriverTripStopModel._parseInt(json['id']),
      childId: DriverTripStopModel._parseInt(json['child_id'] ?? json['id']),
      name: json['name']?.toString() ?? '',
      schoolId: json['school_id'] == null
          ? null
          : DriverTripStopModel._parseInt(json['school_id']),
      schoolName: json['school_name']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, childId, name, schoolId, schoolName];
}

/// محطة رحلة واحدة (GET /driver/trips/{tripId}/stops)
class DriverTripStopModel extends Equatable {
  final int id;
  final String stopType; // home | school
  final int sequenceOrder;
  final String status; // trip_stops.status values
  final int? childId;
  // ⚠️ Single Source of Truth لاسم الطفل هو children[].name من
  // GET /driver/trips/{tripId} (عبر TripDetailsChildModel.name). هذا الحقل
  // (stops[].child_name) يُقرأ ويُحفظ فقط للمطابقة/التوثيق الداخلي، ولا
  // يُستخدم لعرض اسم الطفل بواجهة الرحلة الحية — تجنباً لخلط مصدرين.
  final String? childName;
  final int? schoolId;
  final String? schoolName;
  final String label;
  final double latitude;
  final double longitude;
  final String? eta;
  final int? etaMinutes;

  /// حقول محطة إنقاذ الحافلة المتعطلة (Breakdown Transfer)
  final bool isBreakdownTransfer;
  final bool canBulkConfirm;
  final int transferredChildrenCount;
  final List<TransferredChildModel> transferredChildren;

  const DriverTripStopModel({
    required this.id,
    required this.stopType,
    required this.sequenceOrder,
    required this.status,
    required this.childId,
    required this.childName,
    required this.schoolId,
    required this.schoolName,
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.eta,
    required this.etaMinutes,
    this.isBreakdownTransfer = false,
    this.canBulkConfirm = false,
    this.transferredChildrenCount = 0,
    this.transferredChildren = const [],
  });

  factory DriverTripStopModel.fromJson(Map<String, dynamic> json) {
    final rawTransferred = json['transferred_children'];
    final transferredList = rawTransferred is List
        ? rawTransferred
            .whereType<Map>()
            .map((e) => TransferredChildModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : const <TransferredChildModel>[];

    final isTransfer = json['is_breakdown_transfer'] == true ||
        json['is_breakdown_transfer'] == 1 ||
        json['is_breakdown_transfer']?.toString() == 'true';

    final canConfirm = json['can_bulk_confirm'] == true ||
        json['can_bulk_confirm'] == 1 ||
        json['can_bulk_confirm']?.toString() == 'true';

    final transferCount = _parseInt(
      json['transferred_children_count'] ?? transferredList.length,
    );

    return DriverTripStopModel(
      id: _parseInt(json['id']),
      stopType: json['stop_type']?.toString() ?? '',
      sequenceOrder: _parseInt(json['sequence_order']),
      status: json['status']?.toString() ?? 'pending',
      childId: json['child_id'] == null ? null : _parseInt(json['child_id']),
      childName: json['child_name']?.toString(),
      schoolId: json['school_id'] == null ? null : _parseInt(json['school_id']),
      schoolName: json['school_name']?.toString(),
      label: json['label']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      eta: json['eta']?.toString(),
      etaMinutes: json['eta_minutes'] == null ? null : _parseInt(json['eta_minutes']),
      isBreakdownTransfer: isTransfer,
      canBulkConfirm: canConfirm,
      transferredChildrenCount: transferCount,
      transferredChildren: transferredList,
    );
  }

  bool get isHome => stopType == 'home';
  bool get isSchool => stopType == 'school';

  /// نفس مجموعة الحالات النهائية المعتمدة بـ [LiveTripChildItem] — أي status
  /// غير معروف يبقى "غير منتهٍ" (لا يتحول تلقائياً لمكتمل) لتفادي تلوين
  /// المحطة كمكتملة (أخضر) خطأً على الخريطة.
  static const Set<String> _terminalStatuses = {
    'completed',
    'skipped',
    'skipped_unresponsive',
    'absent',
    'absent_late',
    'absent_pre',
    'dropped_off',
    'dropped_off_school',
    'delivered_home',
    'dropoff_failed',
    'direct_parent_handling',
  };

  bool get isResolved => _terminalStatuses.contains(status);

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
        id,
        stopType,
        sequenceOrder,
        status,
        childId,
        childName,
        schoolId,
        schoolName,
        label,
        latitude,
        longitude,
        eta,
        etaMinutes,
        isBreakdownTransfer,
        canBulkConfirm,
        transferredChildrenCount,
        transferredChildren,
      ];
}

/// غلاف استجابة نقطة المحطات
class DriverTripStopsResponseModel extends Equatable {
  final int tripId;
  final String tripStatus;
  final List<DriverTripStopModel> stops;

  const DriverTripStopsResponseModel({
    required this.tripId,
    required this.tripStatus,
    required this.stops,
  });

  factory DriverTripStopsResponseModel.fromJson(Map<String, dynamic> json) {
    return DriverTripStopsResponseModel(
      tripId: DriverTripStopModel._parseInt(json['trip_id']),
      tripStatus: json['trip_status']?.toString() ?? 'pending',
      stops: json['stops'] is List
          ? (json['stops'] as List)
              .whereType<Map>()
              .map((e) => DriverTripStopModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  @override
  List<Object?> get props => [tripId, tripStatus, stops];
}
