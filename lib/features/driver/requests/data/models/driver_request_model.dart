// نموذج طلبات اشتراك السائق - GET /api/driver/requests
// كل طلب يحتوي على: driver، children (قائمة) وكل طفل يحمل details خاصة به
// إضافة إلى pickup_location و dropoff_location بإحداثياتهما.
import 'package:kids_transport/core/utils/subscription_enums.dart';

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

  /// بيانات السائق كما يرجعها العقد الجديد (قد تكون null في الاستجابات القديمة)
  final DriverReqDriver? driver;

  /// عملة السعر كما يرجعها مسار التفاصيل (مثال: "د.ل")
  final String? currency;

  /// تاريخ الإنشاء منسّقاً من الخادم (created_at_formatted)
  final String? createdAtFormatted;

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
    this.driver,
    this.currency,
    this.createdAtFormatted,
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
  String get timingDisplayLabel => SubscriptionEnums.timingLabel(timing);

  // ── نوع الاشتراك بالعربية (يوم واحد | عدة أيام فقط) ──
  String get subscriptionTypeDisplayLabel =>
      SubscriptionEnums.typeLabel(subscriptionType);

  // ── اتجاه الرحلة بالعربية ──
  String get directionDisplayLabel =>
      SubscriptionEnums.directionLabel(direction);

  /// هل تختلف إعدادات الأطفال داخل الطلب؟ (نوع/اتجاه/فترة/تواريخ)
  bool get hasMixedChildDetails {
    if (children.length < 2) return false;
    final first = children.first.details;
    return children.any((c) =>
        c.details.subscriptionType != first.subscriptionType ||
        c.details.tripDirection != first.tripDirection ||
        c.details.timing != first.timing ||
        c.details.startDate != first.startDate ||
        c.details.endDate != first.endDate);
  }

  /// الحالة تصل نصاً في القائمة، وككائن {"value": "..."} في مسار التفاصيل
  static String _readStatus(dynamic raw) {
    if (raw is Map) {
      return raw['value']?.toString() ?? raw['name']?.toString() ?? 'pending';
    }
    final v = raw?.toString();
    return (v == null || v.isEmpty) ? 'pending' : v;
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

    // العقد الجديد: التفاصيل موجودة داخل كل طفل (details)
    // نستخدم تفاصيل أول طفل كقيم عامة للطلب فقط للعرض المختصر.
    final DriverReqChildDetails? firstDetails =
        childrenList.isNotEmpty ? childrenList.first.details : null;

    return DriverRequestModel(
      id: _parseInt(json['id']) ?? 0,
      parentId: _parseInt(json['parent_id']) ?? 0,
      driverId: _parseInt(json['driver_id']),
      schoolId: _parseInt(json['school_id']) ?? 0,
      timing: json['timing']?.toString() ?? firstDetails?.timing ?? SubscriptionEnums.bothTimings,
      // مسار التفاصيل يرسل status ككائن {"value": "pending"}
      status: _readStatus(json['status']),
      notes: json['notes']?.toString(),
      // children_count من الخادم غير موثوق أحياناً — نعتمد طول القائمة عند اختلافه
      childrenCount: childrenList.isNotEmpty
          ? childrenList.length
          : (_parseInt(json['children_count']) ?? 0),
      pickupTime: json['pickup_time']?.toString(),
      dropoffTime: json['dropoff_time']?.toString(),
      maxWaitingTime: _parseInt(json['max_waiting_time']) ?? 15,
      createdAt: json['created_at']?.toString() ?? '',
      subscriptionType: json['subscription_type']?.toString() ??
          firstDetails?.subscriptionType ??
          SubscriptionEnums.multiDay,
      direction: json['direction']?.toString() ??
          json['trip_direction']?.toString() ??
          firstDetails?.tripDirection ??
          SubscriptionEnums.both,
      startDate: json['start_date']?.toString() ?? firstDetails?.startDate ?? '',
      endDate: json['end_date']?.toString() ?? firstDetails?.endDate ?? '',
      daysCount: _parseInt(json['days_count']) ?? firstDetails?.workingDaysCount,
      totalPrice:
          (json['total_price'] ?? json['total_amount'])?.toString() ?? '0',
      currency: json['currency']?.toString(),
      createdAtFormatted: json['created_at_formatted']?.toString(),
      driver: json['driver'] is Map
          ? DriverReqDriver.fromJson(Map<String, dynamic>.from(json['driver'] as Map))
          : null,
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
      // ملاحظة: العقد الجديد يرسل {id, name, phone} مباشرة بلا كائن user
      phone: userMap?['phone_number']?.toString() ?? json['phone_number']?.toString() ?? json['phone']?.toString(),
      email: userMap?['email']?.toString() ?? json['email']?.toString(),
      avatarUrl: userMap?['avatar_url']?.toString() ??
          json['avatar_url']?.toString() ??
          json['avatar']?.toString(),
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
  final int? age;
  final String? medicalNotes;

  /// ملاحظات ولي الأمر الخاصة بهذا الطفل (notes.child_notes)
  final String? childNotes;
  final int? notificationRadius;
  final String? qrCodeToken;
  final DriverReqChildPivot? pivot;

  /// تفاصيل اشتراك هذا الطفل تحديداً (العقد الجديد: children[].details)
  final DriverReqChildDetails details;

  /// نقطة الانطلاق ونقطة الوصول الخاصة بهذا الطفل
  final DriverReqLocation? pickupLocation;
  final DriverReqLocation? dropoffLocation;

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
    this.age,
    this.medicalNotes,
    this.childNotes,
    this.notificationRadius,
    this.qrCodeToken,
    this.pivot,
    this.details = const DriverReqChildDetails(),
    this.pickupLocation,
    this.dropoffLocation,
  });

  /// سعر اشتراك هذا الطفل (details أولاً ثم pivot القديم)
  double get price =>
      details.pricePerChild ??
      double.tryParse(pivot?.pricePerChild ?? '') ??
      0.0;

  String get priceLabel {
    final p = price;
    return p == p.roundToDouble()
        ? '${p.toInt()} د.ل'
        : '${p.toStringAsFixed(2)} د.ل';
  }

  factory DriverReqChild.fromJson(Map<String, dynamic> json) {
    // مسار التفاصيل يوزّع الملاحظات داخل كائن notes
    final notes = json['notes'] is Map
        ? Map<String, dynamic>.from(json['notes'] as Map)
        : null;

    return DriverReqChild(
      id: DriverRequestModel._parseInt(json['id']) ?? 0,
      parentId: DriverRequestModel._parseInt(json['parent_id']),
      schoolId: DriverRequestModel._parseInt(json['school_id']) ??
          (json['school'] is Map
              ? DriverRequestModel._parseInt((json['school'] as Map)['id'])
              : null),
      addressId: DriverRequestModel._parseInt(json['address_id']),
      name: json['full_name']?.toString() ?? json['name']?.toString() ?? '',
      avatarUrl: json['photo_url']?.toString() ?? json['avatar_url']?.toString(),
      birthDate: json['birth_date']?.toString(),
      grade: DriverRequestModel._parseInt(json['grade']),
      gender: json['gender']?.toString(),
      age: DriverRequestModel._parseInt(json['age']),
      medicalNotes:
          json['medical_notes']?.toString() ?? notes?['medical_notes']?.toString(),
      childNotes:
          json['child_notes']?.toString() ?? notes?['child_notes']?.toString(),
      notificationRadius: DriverRequestModel._parseInt(json['notification_radius']),
      qrCodeToken: json['qr_code_token']?.toString(),
      pivot: json['pivot'] is Map
          ? DriverReqChildPivot.fromJson(
              Map<String, dynamic>.from(json['pivot'] as Map))
          : null,
      details: DriverReqChildDetails.fromChildJson(json),
      // القائمة ترسل pickup_location/dropoff_location أو Home/School،
      // ومسار التفاصيل يرسل home/school
      pickupLocation:
          _reqLocation(json['pickup_location'] ?? json['Home'] ?? json['home']),
      dropoffLocation: _reqLocation(
          json['dropoff_location'] ?? json['School'] ?? json['school']),
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


// ── تفاصيل اشتراك طفل واحد (children[].details) ──
class DriverReqChildDetails {
  final String? subscriptionType; // single_day | multi_day
  final String? tripDirection; // go | return | both
  final String? timing; // MORNING | EVENING | BOTH
  final String? startDate;
  final String? endDate;
  final int? workingDaysCount;
  /// إجمالي اشتراك الطفل للفترة كاملة (سعر الرحلة × عدد أيام العمل)
  final double? pricePerChild;
  final double? distanceKm;

  /// سعر الرحلة الواحدة
  final double? tripPrice;

  const DriverReqChildDetails({
    this.subscriptionType,
    this.tripDirection,
    this.timing,
    this.startDate,
    this.endDate,
    this.workingDaysCount,
    this.pricePerChild,
    this.distanceKm,
    this.tripPrice,
  });

  bool get isEmpty =>
      subscriptionType == null &&
      tripDirection == null &&
      timing == null &&
      startDate == null;

  String get typeLabel => SubscriptionEnums.typeLabel(subscriptionType);
  String get directionLabel => SubscriptionEnums.directionLabel(tripDirection);
  String get timingLabel => SubscriptionEnums.timingLabel(timing);

  factory DriverReqChildDetails.fromJson(Map<String, dynamic> json) {
    return DriverReqChildDetails(
      subscriptionType: json['subscription_type']?.toString(),
      tripDirection:
          json['trip_direction']?.toString() ?? json['direction']?.toString(),
      timing: json['timing']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      workingDaysCount: DriverRequestModel._parseInt(json['working_days_count']),
      pricePerChild: _toDouble(json['price_per_child'] ?? json['total_price']),
      distanceKm: _toDouble(json['distance_km']),
      tripPrice: _toDouble(json['trip_price']),
    );
  }

  /// يبني التفاصيل من كائن الطفل مهما كان شكل الاستجابة:
  ///  • القائمة      : children[].details { ... }
  ///  • مسار التفاصيل: trip_details + subscription_period + pricing
  factory DriverReqChildDetails.fromChildJson(Map<String, dynamic> child) {
    if (child['details'] is Map) {
      return DriverReqChildDetails.fromJson(
          Map<String, dynamic>.from(child['details'] as Map));
    }

    Map<String, dynamic> sub(String key) => child[key] is Map
        ? Map<String, dynamic>.from(child[key] as Map)
        : <String, dynamic>{};

    final trip = sub('trip_details');
    final period = sub('subscription_period');
    final pricing = sub('pricing');

    if (trip.isEmpty && period.isEmpty && pricing.isEmpty) {
      return const DriverReqChildDetails();
    }

    return DriverReqChildDetails(
      subscriptionType: trip['subscription_type']?.toString(),
      tripDirection:
          trip['trip_direction']?.toString() ?? trip['direction']?.toString(),
      timing: trip['timing']?.toString(),
      startDate: period['start_date']?.toString(),
      endDate: period['end_date']?.toString(),
      workingDaysCount:
          DriverRequestModel._parseInt(period['working_days_count']),
      pricePerChild:
          _toDouble(pricing['total_price'] ?? pricing['price_per_child']),
      distanceKm: _toDouble(pricing['distance_km']),
      tripPrice: _toDouble(pricing['trip_price']),
    );
  }
}

// ── موقع (pickup_location / dropoff_location) ──
class DriverReqLocation {
  final int? id;

  /// اسم الموقع: "منزلي" أو "مدرسة النور الابتدائية"
  final String? name;

  /// العنوان التفصيلي — قد يرجع كنص بديل من الخادم
  final String? address;
  final double? latitude;
  final double? longitude;

  const DriverReqLocation({
    this.id,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
  });

  /// نصوص بديلة يرسلها الخادم بدل العنوان الحقيقي — لا تُعرض للسائق
  static const List<String> _placeholders = [
    'عنوان غير متوفر',
    'غير متوفر',
    'غير محدد',
    'null',
  ];

  static bool _isPlaceholder(String? v) {
    if (v == null) return true;
    final t = v.trim();
    return t.isEmpty || _placeholders.contains(t);
  }

  bool get hasName => !_isPlaceholder(name);
  bool get hasRealAddress => !_isPlaceholder(address);

  String get displayName {
    if (hasName) return name!.trim();
    if (hasRealAddress) return address!.trim();
    return 'غير محدد';
  }

  /// العنوان التفصيلي — null إن لم يوجد، أو إن كان نفسه الاسم المعروض
  String? get displayAddress {
    if (!hasRealAddress) return null;
    final a = address!.trim();
    if (hasName && a == name!.trim()) return null;
    if (!hasName) return null; // العنوان صار هو الاسم المعروض
    return a;
  }

  bool get hasCoordinates => latitude != null && longitude != null;

  factory DriverReqLocation.fromJson(Map<String, dynamic> json) =>
      DriverReqLocation(
        id: DriverRequestModel._parseInt(json['id']),
        name: json['name']?.toString() ?? json['label']?.toString(),
        address: json['address']?.toString(),
        latitude: _toDouble(json['latitude'] ?? json['lat']),
        longitude: _toDouble(json['longitude'] ?? json['lng']),
      );
}

// ── السائق في العقد الجديد ──
class DriverReqDriver {
  final int id;
  final String name;
  final String? phone;
  final String? photo;

  const DriverReqDriver({
    required this.id,
    required this.name,
    this.phone,
    this.photo,
  });

  factory DriverReqDriver.fromJson(Map<String, dynamic> json) => DriverReqDriver(
        id: DriverRequestModel._parseInt(json['id']) ?? 0,
        name: json['name']?.toString() ?? '',
        phone: json['phone']?.toString(),
        photo: json['photo']?.toString(),
      );
}

DriverReqLocation? _reqLocation(dynamic raw) {
  if (raw is! Map) return null;
  return DriverReqLocation.fromJson(Map<String, dynamic>.from(raw));
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}
