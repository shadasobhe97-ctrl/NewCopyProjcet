// نموذج طلبات اشتراك السائق - GET /api/driver/requests
// كل طلب يحتوي على: parent، school، children (قائمة) مع pivot

class DriverRequestModel {
  final int id;
  final int parentId;
  final int? driverId;
  final int schoolId;
  final String timing; // MORNING | AFTERNOON | BOTH
  final String status; // pending | accepted | approved | rejected | cancelled
  final String? notes;
  final int childrenCount;
  final String? pickupTime;
  final String? dropoffTime;
  final int maxWaitingTime;
  final String createdAt;
  final String? subscriptionType; // monthly | weekly | etc.
  final String? direction; // both | go | return
  final String? startDate;
  final String? endDate;
  final double totalPrice;
  final String? rejectionReason;
  final DriverReqParent parent;
  final DriverReqSchool school;
  final List<DriverReqChild> children;

  const DriverRequestModel({
    required this.id,
    required this.parentId,
    this.driverId,
    required this.schoolId,
    required this.timing,
    required this.status,
    this.notes,
    required this.childrenCount,
    this.pickupTime,
    this.dropoffTime,
    required this.maxWaitingTime,
    required this.createdAt,
    this.subscriptionType,
    this.direction,
    this.startDate,
    this.endDate,
    required this.totalPrice,
    this.rejectionReason,
    required this.parent,
    required this.school,
    required this.children,
  });

  // ── الحالة بالعربية ──
  String get statusDisplayLabel {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'معلق';
      case 'accepted':
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  // ── الفترة بالعربية ──
  String get timingDisplayLabel {
    switch (timing.toUpperCase()) {
      case 'MORNING':
        return 'صباحي';
      case 'AFTERNOON':
        return 'مسائي';
      case 'BOTH':
        return 'ذهاب وإياب';
      default:
        return timing;
    }
  }

  // ── نوع الاشتراك بالعربية ──
  String get subscriptionTypeDisplayLabel {
    switch (subscriptionType?.toLowerCase()) {
      case 'monthly':
        return 'شهري';
      case 'weekly':
        return 'أسبوعي';
      case 'daily':
        return 'يومي';
      default:
        return subscriptionType ?? 'غير محدد';
    }
  }

  // ── اتجاه الرحلة بالعربية ──
  String get directionDisplayLabel {
    switch (direction?.toLowerCase()) {
      case 'both':
        return 'ذهاب وإياب';
      case 'go':
        return 'ذهاب فقط';
      case 'return':
        return 'إياب فقط';
      default:
        return direction ?? 'غير محدد';
    }
  }

  static int? _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '');
  }

  static double? _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '');
  }

  factory DriverRequestModel.fromJson(Map<String, dynamic> json) {
    // children
    final rawChildren = json['children'];
    final List<DriverReqChild> childrenList = [];
    if (rawChildren is List) {
      for (final c in rawChildren) {
        if (c is Map) {
          childrenList
              .add(DriverReqChild.fromJson(Map<String, dynamic>.from(c)));
        }
      }
    }

    return DriverRequestModel(
      id: _parseInt(json['id']) ?? 0,
      parentId: _parseInt(json['parent_id']) ?? 0,
      driverId: _parseInt(json['driver_id']),
      schoolId: _parseInt(json['school_id']) ?? 0,
      timing: json['timing']?.toString() ?? 'MORNING',
      status: json['status']?.toString() ?? 'pending',
      notes: json['notes']?.toString(),
      childrenCount: _parseInt(json['children_count']) ?? childrenList.length,
      pickupTime: json['pickup_time']?.toString(),
      dropoffTime: json['dropoff_time']?.toString(),
      maxWaitingTime: _parseInt(json['max_waiting_time']) ?? 15,
      createdAt: json['created_at']?.toString() ?? '',
      subscriptionType: json['subscription_type']?.toString(),
      direction: json['direction']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      totalPrice: _parseDouble(json['total_price']) ?? 0.0,
      rejectionReason: json['rejection_reason']?.toString(),
      parent: json['parent'] is Map
          ? DriverReqParent.fromJson(
              Map<String, dynamic>.from(json['parent'] as Map))
          : DriverReqParent.empty(),
      school: json['school'] is Map
          ? DriverReqSchool.fromJson(
              Map<String, dynamic>.from(json['school'] as Map))
          : DriverReqSchool.empty(),
      children: childrenList,
    );
  }
}

// ── ولي الأمر ──
class DriverReqParent {
  final int id;
  final String name;
  final String? phone;
  final String? avatarUrl;

  const DriverReqParent({
    required this.id,
    required this.name,
    this.phone,
    this.avatarUrl,
  });

  factory DriverReqParent.fromJson(Map<String, dynamic> json) {
    // ريان غوط الشعال أرسل أن الاسم والهاتف داخل كائن user المتداخل
    final userMap = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : null;

    return DriverReqParent(
      id: json['id'] as int? ?? 0,
      name: userMap?['full_name']?.toString() ?? json['full_name']?.toString() ?? json['name']?.toString() ?? '',
      phone: userMap?['phone_number']?.toString() ?? json['phone_number']?.toString() ?? json['phone']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
    );
  }

  factory DriverReqParent.empty() => const DriverReqParent(id: 0, name: '');
}

// ── المدرسة ──
class DriverReqSchool {
  final int id;
  final String name;
  final String? address;

  const DriverReqSchool({
    required this.id,
    required this.name,
    this.address,
  });

  factory DriverReqSchool.fromJson(Map<String, dynamic> json) {
    return DriverReqSchool(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString(),
    );
  }

  factory DriverReqSchool.empty() => const DriverReqSchool(id: 0, name: '');
}

// ── الطفل (مع بيانات الـ pivot) ──
class DriverReqChild {
  final int id;
  final String name;
  final String? avatarUrl;
  final String? grade;
  final DriverReqChildPivot? pivot;

  const DriverReqChild({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.grade,
    this.pivot,
  });

  factory DriverReqChild.fromJson(Map<String, dynamic> json) {
    return DriverReqChild(
      id: json['id'] as int? ?? 0,
      name: json['full_name']?.toString() ?? json['name']?.toString() ?? '',
      avatarUrl: json['photo_url']?.toString() ?? json['avatar_url']?.toString(),
      grade: json['grade']?.toString(),
      pivot: json['pivot'] is Map
          ? DriverReqChildPivot.fromJson(
              Map<String, dynamic>.from(json['pivot'] as Map))
          : null,
    );
  }
}

// ── بيانات رحلة الطفل (pivot) ──
class DriverReqChildPivot {
  final int? pickupAddressId;
  final double? homeLat;
  final double? homeLng;
  final String? homeLabel;
  final int? dropoffAddressId;
  final double? schoolLat;
  final double? schoolLng;

  const DriverReqChildPivot({
    this.pickupAddressId,
    this.homeLat,
    this.homeLng,
    this.homeLabel,
    this.dropoffAddressId,
    this.schoolLat,
    this.schoolLng,
  });

  factory DriverReqChildPivot.fromJson(Map<String, dynamic> json) {
    return DriverReqChildPivot(
      pickupAddressId: json['pickup_address_id'] as int?,
      homeLat: (json['home_lat'] as num?)?.toDouble(),
      homeLng: (json['home_lng'] as num?)?.toDouble(),
      homeLabel: json['home_label']?.toString(),
      dropoffAddressId: json['dropoff_address_id'] as int?,
      schoolLat: (json['school_lat'] as num?)?.toDouble(),
      schoolLng: (json['school_lng'] as num?)?.toDouble(),
    );
  }
}
