import 'package:kids_transport/core/utils/subscription_enums.dart';

// =============================================================================
// النماذج المتداخلة المشتركة لطلبات واشتراكات السائق (Shared Nested Models)
// مطابقة بدقة لعقد الاستجابة الجديد (New Backend API Response)
// =============================================================================

/// 1. نموذج بيانات ولي الأمر (على مستوى الطلب/الاشتراك الموحد)
class DriverParentModel {
  final int id;
  final String name;
  final String? phone;
  final String? alternativePhone;
  final String? gender;
  final String? photoUrl;

  const DriverParentModel({
    required this.id,
    required this.name,
    this.phone,
    this.alternativePhone,
    this.gender,
    this.photoUrl,
  });

  factory DriverParentModel.fromJson(Map<String, dynamic> json) {
    return DriverParentModel(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? json['full_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['phone_number']?.toString(),
      alternativePhone: json['alternative_phone']?.toString(),
      gender: json['gender']?.toString(),
      photoUrl: json['photo_url']?.toString() ??
          json['avatar_url']?.toString() ??
          json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'alternative_phone': alternativePhone,
        'gender': gender,
        'photo_url': photoUrl,
      };
}

/// 2. نموذج بيانات الاشتراك الموحد (على مستوى الطلب/الاشتراك)
class SubscriptionInfoModel {
  final String type;
  final String? typeLabel;
  final String direction;
  final String? directionLabel;
  final String? startDate;
  final String? endDate;
  final int? workingDaysCount;

  const SubscriptionInfoModel({
    required this.type,
    this.typeLabel,
    required this.direction,
    this.directionLabel,
    this.startDate,
    this.endDate,
    this.workingDaysCount,
  });

  /// لا تعرض "اشتراك شهري" أو "شهري" في واجهة المستخدم نهائياً
  String get typeDisplayLabel => SubscriptionEnums.typeLabel(type);

  /// اتجاه الرحلة المعتمد بالعربية
  String get directionDisplayLabel =>
      SubscriptionEnums.directionLabel(direction);

  factory SubscriptionInfoModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfoModel(
      type: json['type']?.toString() ?? 'multi_day',
      typeLabel: json['type_label']?.toString(),
      direction: json['direction']?.toString() ?? 'both',
      directionLabel: json['direction_label']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      workingDaysCount: _parseInt(json['working_days_count']),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'type_label': typeLabel,
        'direction': direction,
        'direction_label': directionLabel,
        'start_date': startDate,
        'end_date': endDate,
        'working_days_count': workingDaysCount,
      };
}

/// 3. نموذج عنوان المنزل / نقطة الانطلاق
class DriverHomeAddressModel {
  final int? id;
  final String? label;
  final double? lat;
  final double? lng;

  const DriverHomeAddressModel({
    this.id,
    this.label,
    this.lat,
    this.lng,
  });

  bool get hasCoordinates => lat != null && lng != null;

  String get displayName =>
      (label != null && label!.trim().isNotEmpty && label != 'null')
          ? label!.trim()
          : 'المنزل';

  factory DriverHomeAddressModel.fromJson(Map<String, dynamic> json) {
    return DriverHomeAddressModel(
      id: _parseInt(json['id']),
      label: json['label']?.toString() ??
          json['name']?.toString() ??
          json['address']?.toString(),
      lat: _parseDouble(json['lat'] ?? json['latitude']),
      lng: _parseDouble(json['lng'] ?? json['longitude']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'lat': lat,
        'lng': lng,
      };
}

/// 4. نموذج المدرسة للطفل
class DriverSchoolModel {
  final int? id;
  final String name;
  final double? lat;
  final double? lng;

  const DriverSchoolModel({
    this.id,
    required this.name,
    this.lat,
    this.lng,
  });

  bool get hasCoordinates => lat != null && lng != null;

  factory DriverSchoolModel.fromJson(Map<String, dynamic> json) {
    return DriverSchoolModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      lat: _parseDouble(json['lat'] ?? json['latitude']),
      lng: _parseDouble(json['lng'] ?? json['longitude']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lat': lat,
        'lng': lng,
      };
}

/// 5. نموذج التسعير المالي الموحد للاشتراك بالكامل
class DriverSubscriptionPricingModel {
  final double? totalPrice;
  final double? discountAmount;
  final double? totalAmountAfterDiscount;
  final double? platformCommissionTotal;
  final double? driverNetTotal;

  const DriverSubscriptionPricingModel({
    this.totalPrice,
    this.discountAmount,
    this.totalAmountAfterDiscount,
    this.platformCommissionTotal,
    this.driverNetTotal,
  });

  String get formattedTotal => totalAmountAfterDiscount != null
      ? _formatMoney(totalAmountAfterDiscount!)
      : (totalPrice != null ? _formatMoney(totalPrice!) : '0 د.ل');

  String get formattedDriverNet =>
      driverNetTotal != null ? _formatMoney(driverNetTotal!) : '0 د.ل';

  factory DriverSubscriptionPricingModel.fromJson(Map<String, dynamic> json) {
    return DriverSubscriptionPricingModel(
      totalPrice: _parseDouble(json['total_price']),
      discountAmount: _parseDouble(json['discount_amount']),
      totalAmountAfterDiscount: _parseDouble(
          json['total_amount_after_discount'] ?? json['total_after_discount']),
      platformCommissionTotal:
          _parseDouble(json['platform_commission_total']),
      driverNetTotal: _parseDouble(json['driver_net_total']),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_price': totalPrice,
        'discount_amount': discountAmount,
        'total_amount_after_discount': totalAmountAfterDiscount,
        'platform_commission_total': platformCommissionTotal,
        'driver_net_total': driverNetTotal,
      };
}

/// 6. نموذج التسعير الخاص بالطفل الواحد
class DriverChildPricingModel {
  final double? priceBeforeDiscount;
  final double? discountPercentage;
  final double? discountAmount;
  final double? priceAfterDiscount;
  final double? platformCommissionAmount;
  final double? driverNetPrice;

  const DriverChildPricingModel({
    this.priceBeforeDiscount,
    this.discountPercentage,
    this.discountAmount,
    this.priceAfterDiscount,
    this.platformCommissionAmount,
    this.driverNetPrice,
  });

  String get formattedPrice => priceAfterDiscount != null
      ? _formatMoney(priceAfterDiscount!)
      : (priceBeforeDiscount != null
          ? _formatMoney(priceBeforeDiscount!)
          : '0 د.ل');

  String get formattedDriverNet =>
      driverNetPrice != null ? _formatMoney(driverNetPrice!) : '0 د.ل';

  factory DriverChildPricingModel.fromJson(Map<String, dynamic> json) {
    return DriverChildPricingModel(
      priceBeforeDiscount: _parseDouble(json['price_before_discount'] ??
          json['trip_price'] ??
          json['price_per_child']),
      discountPercentage: _parseDouble(json['discount_percentage']),
      discountAmount: _parseDouble(json['discount_amount']),
      priceAfterDiscount: _parseDouble(json['price_after_discount'] ??
          json['price_per_child'] ??
          json['total_price']),
      platformCommissionAmount: _parseDouble(
          json['platform_commission_amount'] ?? json['platform_commission']),
      driverNetPrice: _parseDouble(json['driver_net_price']),
    );
  }

  Map<String, dynamic> toJson() => {
        'price_before_discount': priceBeforeDiscount,
        'discount_percentage': discountPercentage,
        'discount_amount': discountAmount,
        'price_after_discount': priceAfterDiscount,
        'platform_commission_amount': platformCommissionAmount,
        'driver_net_price': driverNetPrice,
      };
}

/// 7. نموذج بيانات الاشتراك المفعل الخاصة بالطفل (Nullable)
class DriverChildActiveSubscriptionModel {
  final int? id;
  final String? status;
  final String? statusLabel;
  final int? routeId;
  final String? pickupTime;
  final String? dropoffTime;

  const DriverChildActiveSubscriptionModel({
    this.id,
    this.status,
    this.statusLabel,
    this.routeId,
    this.pickupTime,
    this.dropoffTime,
  });

  String get displayStatus =>
      statusLabel ?? SubscriptionEnums.statusLabel(status);

  factory DriverChildActiveSubscriptionModel.fromJson(
      Map<String, dynamic> json) {
    return DriverChildActiveSubscriptionModel(
      id: _parseInt(json['id']),
      status: json['status']?.toString(),
      statusLabel: json['status_label']?.toString(),
      routeId: _parseInt(json['route_id']),
      pickupTime: json['pickup_time']?.toString(),
      dropoffTime: json['dropoff_time']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'status_label': statusLabel,
        'route_id': routeId,
        'pickup_time': pickupTime,
        'dropoff_time': dropoffTime,
      };
}

/// 8. نموذج بيانات الطفل داخل نفس الاشتراك
class DriverChildModel {
  final int childId;
  final String name;
  final String? photoUrl;
  final int? age;
  final String? gender;
  final dynamic grade;
  final String? gradeLabel;
  final DriverSchoolModel? school;
  final String? timing; // Nullable
  final double? distanceKm;
  final String? medicalNotes;
  final DriverChildPricingModel? pricing;
  final DriverChildActiveSubscriptionModel? activeSubscription; // Nullable

  const DriverChildModel({
    required this.childId,
    required this.name,
    this.photoUrl,
    this.age,
    this.gender,
    this.grade,
    this.gradeLabel,
    this.school,
    this.timing,
    this.distanceKm,
    this.medicalNotes,
    this.pricing,
    this.activeSubscription,
  });

  String get avatarInitials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '؟';
    final parts = trimmed.split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return trimmed[0];
  }

  String get displayGrade {
    if (gradeLabel != null && gradeLabel!.isNotEmpty) return gradeLabel!;
    if (grade != null && grade.toString().isNotEmpty) return 'الصف $grade';
    return '';
  }

  String get genderDisplay => SubscriptionEnums.genderLabel(gender);

  String get timingDisplay => timing != null && timing!.isNotEmpty
      ? SubscriptionEnums.timingLabel(timing)
      : 'غير محدد';

  factory DriverChildModel.fromJson(Map<String, dynamic> json) {
    final cid = _parseInt(json['child_id'] ?? json['id']) ?? 0;
    final schoolJson = json['school'] is Map
        ? Map<String, dynamic>.from(json['school'] as Map)
        : null;
    final pricingJson = json['pricing'] is Map
        ? Map<String, dynamic>.from(json['pricing'] as Map)
        : null;
    final activeSubJson = json['active_subscription'] is Map
        ? Map<String, dynamic>.from(json['active_subscription'] as Map)
        : null;

    final medNotes = json['medical_notes']?.toString() ??
        (json['notes'] is Map
            ? (json['notes'] as Map)['child_notes']?.toString()
            : json['notes']?.toString());

    return DriverChildModel(
      childId: cid,
      name: json['name']?.toString() ?? json['full_name']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString() ??
          json['photo']?.toString() ??
          json['avatar_url']?.toString(),
      age: _parseInt(json['age']),
      gender: json['gender']?.toString(),
      grade: json['grade'],
      gradeLabel: json['grade_label']?.toString(),
      school:
          schoolJson != null ? DriverSchoolModel.fromJson(schoolJson) : null,
      timing: json['timing']?.toString(),
      distanceKm: _parseDouble(json['distance_km']),
      medicalNotes: (medNotes != null &&
              medNotes.trim().isNotEmpty &&
              medNotes != 'لا يوجد' &&
              medNotes != 'null')
          ? medNotes.trim()
          : (medNotes == 'لا يوجد' ? 'لا توجد ملاحظات' : null),
      pricing: pricingJson != null
          ? DriverChildPricingModel.fromJson(pricingJson)
          : null,
      activeSubscription: activeSubJson != null
          ? DriverChildActiveSubscriptionModel.fromJson(activeSubJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'child_id': childId,
        'name': name,
        'photo_url': photoUrl,
        'age': age,
        'gender': gender,
        'grade': grade,
        'grade_label': gradeLabel,
        'school': school?.toJson(),
        'timing': timing,
        'distance_km': distanceKm,
        'medical_notes': medicalNotes,
        'pricing': pricing?.toJson(),
        'active_subscription': activeSubscription?.toJson(),
      };
}

// ─────────────────────────────────────────────
// دوال مساعدة آمنة لمعالجة الـ JSON والأرقام
// ─────────────────────────────────────────────

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

double? _parseDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

String _formatMoney(double v) => v == v.roundToDouble()
    ? '${v.toInt()} د.ل'
    : '${v.toStringAsFixed(2)} د.ل';
