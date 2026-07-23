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
  final String subscriptionType; // monthly | weekly | etc.
  final String direction; // both | go | return
  final String startDate;
  final String endDate;
  final int? daysCount;
  final String totalPrice;
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
    required this.subscriptionType,
    required this.direction,
    required this.startDate,
    required this.endDate,
    this.daysCount,
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
    switch (subscriptionType.toLowerCase()) {
      case 'monthly':
        return 'شهري';
      case 'weekly':
        return 'أسبوعي';
      case 'daily':
        return 'يومي';
      default:
        return subscriptionType;
    }
  }

  // ── اتجاه الرحلة بالعربية ──
  String get directionDisplayLabel {
    switch (direction.toLowerCase()) {
      case 'both':
        return 'ذهاب وإياب';
      case 'go':
        return 'ذهاب فقط';
      case 'return':
        return 'إياب فقط';
      default:
        return direction;
    }
  }

  static int? _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '');
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
      subscriptionType: json['subscription_type']?.toString() ?? 'monthly',
      direction: json['direction']?.toString() ?? 'both',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      daysCount: _parseInt(json['days_count']),
      totalPrice: json['total_price']?.toString() ?? '0',
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
  final int? userId;
  final bool? isTrusted;
  final String name;
  final String? phone;
  final String? email;
  final String? avatarUrl;

  const DriverReqParent({
    required this.id,
    this.userId,
    this.isTrusted,
    required this.name,
    this.phone,
    this.email,
    this.avatarUrl,
  });

  factory DriverReqParent.fromJson(Map<String, dynamic> json) {
    // ريان غوط الشعال أرسل أن الاسم والهاتف داخل كائن user المتداخل
    final userMap = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : null;

    return DriverReqParent(
      id: json['id'] as int? ?? 0,
      userId: DriverRequestModel._parseInt(json['user_id']),
      isTrusted: json['is_trusted'] is bool ? json['is_trusted'] : (json['is_trusted']?.toString() == '1' ? true : null),
      name: userMap?['full_name']?.toString() ?? json['full_name']?.toString() ?? json['name']?.toString() ?? '',
      phone: userMap?['phone_number']?.toString() ?? json['phone_number']?.toString() ?? json['phone']?.toString(),
      email: userMap?['email']?.toString() ?? json['email']?.toString(),
      avatarUrl: userMap?['avatar_url']?.toString() ?? json['avatar_url']?.toString(),
    );
  }

  factory DriverReqParent.empty() => const DriverReqParent(id: 0, name: '');
}

// ── المدرسة ──
class DriverReqSchool {
  final int id;
  final String name;
  final int? zoneId;
  final String? lat;
  final String? lng;
  final String? address;
  final String? status;

  const DriverReqSchool({
    required this.id,
    required this.name,
    this.zoneId,
    this.lat,
    this.lng,
    this.address,
    this.status,
  });

  factory DriverReqSchool.fromJson(Map<String, dynamic> json) {
    return DriverReqSchool(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      zoneId: DriverRequestModel._parseInt(json['zone_id']),
      lat: json['lat']?.toString(),
      lng: json['lng']?.toString(),
      address: json['address']?.toString(),
      status: json['status']?.toString(),
    );
  }

  factory DriverReqSchool.empty() => const DriverReqSchool(id: 0, name: '');
}

// ── الطفل (مع بيانات الـ pivot) ──
class DriverReqChild {
  final int id;
  final int? parentId;
  final int? schoolId;
  final int? addressId;
  final String name;
  final String? avatarUrl;
  final String? birthDate;
  final int? grade;
  final String? gender;
  final String? medicalNotes;
  final int? notificationRadius;
  final String? qrCodeToken;
  final DriverReqChildPivot? pivot;

  const DriverReqChild({
    required this.id,
    this.parentId,
    this.schoolId,
    this.addressId,
    required this.name,
    this.avatarUrl,
    this.birthDate,
    this.grade,
    this.gender,
    this.medicalNotes,
    this.notificationRadius,
    this.qrCodeToken,
    this.pivot,
  });

  factory DriverReqChild.fromJson(Map<String, dynamic> json) {
    return DriverReqChild(
      id: DriverRequestModel._parseInt(json['id']) ?? 0,
      parentId: DriverRequestModel._parseInt(json['parent_id']),
      schoolId: DriverRequestModel._parseInt(json['school_id']),
      addressId: DriverRequestModel._parseInt(json['address_id']),
      name: json['full_name']?.toString() ?? json['name']?.toString() ?? '',
      avatarUrl: json['photo_url']?.toString() ?? json['avatar_url']?.toString(),
      birthDate: json['birth_date']?.toString(),
      grade: DriverRequestModel._parseInt(json['grade']),
      gender: json['gender']?.toString(),
      medicalNotes: json['medical_notes']?.toString(),
      notificationRadius: DriverRequestModel._parseInt(json['notification_radius']),
      qrCodeToken: json['qr_code_token']?.toString(),
      pivot: json['pivot'] is Map
          ? DriverReqChildPivot.fromJson(
              Map<String, dynamic>.from(json['pivot'] as Map))
          : null,
    );
  }
}

// ── بيانات رحلة الطفل (pivot) ──
class DriverReqChildPivot {
  final int requestId;
  final int childId;
  final int? pickupAddressId;
  final String? homeLat;
  final String? homeLng;
  final String? homeLabel;
  final int? dropoffAddressId;
  final String? schoolLat;
  final String? schoolLng;
  final String? schoolLabel;
  final String pricePerChild;
  final String? childNotes;

  const DriverReqChildPivot({
    required this.requestId,
    required this.childId,
    this.pickupAddressId,
    this.homeLat,
    this.homeLng,
    this.homeLabel,
    this.dropoffAddressId,
    this.schoolLat,
    this.schoolLng,
    this.schoolLabel,
    required this.pricePerChild,
    this.childNotes,
  });

  factory DriverReqChildPivot.fromJson(Map<String, dynamic> json) {
    return DriverReqChildPivot(
      requestId: DriverRequestModel._parseInt(json['request_id']) ?? 0,
      childId: DriverRequestModel._parseInt(json['child_id']) ?? 0,
      pickupAddressId: DriverRequestModel._parseInt(json['pickup_address_id']),
      homeLat: json['home_lat']?.toString(),
      homeLng: json['home_lng']?.toString(),
      homeLabel: json['home_label']?.toString(),
      dropoffAddressId: DriverRequestModel._parseInt(json['dropoff_address_id']),
      schoolLat: json['school_lat']?.toString(),
      schoolLng: json['school_lng']?.toString(),
      schoolLabel: json['school_label']?.toString(),
      pricePerChild: json['price_per_child']?.toString() ?? '0',
      childNotes: json['child_notes']?.toString(),
    );
  }
}

// ── Wrapper class for Pagination ──
class PaginatedDriverRequests {
  final List<DriverRequestModel> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final String? nextPageUrl;

  PaginatedDriverRequests({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    this.nextPageUrl,
  });

  bool get hasMore => currentPage < lastPage;
}
