import 'package:kids_transport/core/utils/subscription_enums.dart';

/// نموذج طلب الاشتراك الجديد — GET /api/parent/requests/{id}
/// بيانات الاشتراك مشتركة لكل الأطفال، وكل طفل له تسعير خاص
class RequestModel {
  final int id;
  final String status;
  final String? statusLabel;
  final RequestDriver driver;
  final RequestSubscriptionInfo subscription; // مشترك
  final RequestHomeAddress? homeAddress;
  final int childrenCount;
  final RequestRootPricing? pricing; // إجمالي كل الأطفال
  final List<RequestChild> children;
  final String? notes;
  final String createdAt;

  const RequestModel({
    required this.id,
    required this.status,
    this.statusLabel,
    required this.driver,
    required this.subscription,
    this.homeAddress,
    required this.childrenCount,
    this.pricing,
    required this.children,
    this.notes,
    required this.createdAt,
  });

  String get statusDisplayLabel =>
      SubscriptionEnums.statusLabel(status, fallbackLabel: statusLabel);

  String get childrenNames => children.map((c) => c.name).join('، ');

  String get formattedTotalPrice {
    final amount = pricing?.totalAmountAfterDiscount ?? pricing?.totalPrice ?? 0.0;
    if (amount == amount.toInt()) return '${amount.toInt()} د.ل';
    return '${amount.toStringAsFixed(2)} د.ل';
  }

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    final childrenList = (json['children'] as List<dynamic>? ?? [])
        .map((e) => RequestChild.fromJson(e as Map<String, dynamic>))
        .toList();

    return RequestModel(
      id: _parseInt(json['id']) ?? 0,
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString(),
      driver: RequestDriver.fromJson(
          json['driver'] as Map<String, dynamic>? ?? {}),
      subscription: RequestSubscriptionInfo.fromJson(
          json['subscription'] as Map<String, dynamic>? ?? {}),
      homeAddress: json['home_address'] is Map
          ? RequestHomeAddress.fromJson(
              Map<String, dynamic>.from(json['home_address'] as Map))
          : null,
      childrenCount:
          _parseInt(json['children_count']) ?? childrenList.length,
      pricing: json['pricing'] is Map
          ? RequestRootPricing.fromJson(
              Map<String, dynamic>.from(json['pricing'] as Map))
          : null,
      children: childrenList,
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        if (statusLabel != null) 'status_label': statusLabel,
        'driver': driver.toJson(),
        'subscription': subscription.toJson(),
        if (homeAddress != null) 'home_address': homeAddress!.toJson(),
        'children_count': childrenCount,
        if (pricing != null) 'pricing': pricing!.toJson(),
        'children': children.map((c) => c.toJson()).toList(),
        if (notes != null) 'notes': notes,
        'created_at': createdAt,
      };
}

// ── السائق ──
class RequestDriver {
  final int id;
  final String name;
  final String? phone;
  final String? alternativePhone;
  final String? gender;
  final String? photoUrl;
  final RequestVehicle? vehicle;

  const RequestDriver({
    required this.id,
    required this.name,
    this.phone,
    this.alternativePhone,
    this.gender,
    this.photoUrl,
    this.vehicle,
  });

  bool get isFemale => gender == 'female';

  factory RequestDriver.fromJson(Map<String, dynamic> json) => RequestDriver(
        id: _parseInt(json['id']) ?? 0,
        name: json['name']?.toString() ??
            json['full_name']?.toString() ??
            '',
        phone: json['phone']?.toString(),
        alternativePhone: json['alternative_phone']?.toString(),
        gender: json['gender']?.toString(),
        photoUrl: json['photo_url']?.toString() ??
            json['photo']?.toString() ??
            json['avatar_url']?.toString(),
        vehicle: json['vehicle'] is Map
            ? RequestVehicle.fromJson(
                Map<String, dynamic>.from(json['vehicle'] as Map))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (phone != null) 'phone': phone,
        if (gender != null) 'gender': gender,
        if (photoUrl != null) 'photo_url': photoUrl,
        if (vehicle != null) 'vehicle': vehicle!.toJson(),
      };
}

// ── السيارة ──
class RequestVehicle {
  final bool hasAc;
  final int? capacity;
  final String? plateNumber;

  const RequestVehicle({
    required this.hasAc,
    this.capacity,
    this.plateNumber,
  });

  factory RequestVehicle.fromJson(Map<String, dynamic> json) => RequestVehicle(
        hasAc: json['has_ac'] == true,
        capacity: _parseInt(json['capacity']),
        plateNumber: json['plate_number']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'has_ac': hasAc,
        if (capacity != null) 'capacity': capacity,
        if (plateNumber != null) 'plate_number': plateNumber,
      };
}

// ── بيانات الاشتراك المشتركة ──
class RequestSubscriptionInfo {
  final String type;
  final String? typeLabel;
  final String direction;
  final String? directionLabel;
  final String startDate;
  final String? endDate;
  final int workingDaysCount;

  const RequestSubscriptionInfo({
    required this.type,
    this.typeLabel,
    required this.direction,
    this.directionLabel,
    required this.startDate,
    this.endDate,
    required this.workingDaysCount,
  });

  String get typeDisplayLabel =>
      typeLabel ?? SubscriptionEnums.typeLabel(type);

  String get directionDisplayLabel =>
      directionLabel ?? SubscriptionEnums.directionLabel(direction);

  factory RequestSubscriptionInfo.fromJson(Map<String, dynamic> json) =>
      RequestSubscriptionInfo(
        type: json['type']?.toString() ?? '',
        typeLabel: json['type_label']?.toString(),
        direction: json['direction']?.toString() ??
            json['trip_direction']?.toString() ??
            '',
        directionLabel: json['direction_label']?.toString(),
        startDate: json['start_date']?.toString() ?? '',
        endDate: json['end_date']?.toString(),
        workingDaysCount: _parseInt(json['working_days_count']) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        if (typeLabel != null) 'type_label': typeLabel,
        'direction': direction,
        if (directionLabel != null) 'direction_label': directionLabel,
        'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        'working_days_count': workingDaysCount,
      };
}

// ── عنوان المنزل ──
class RequestHomeAddress {
  final int? id;
  final String? label;
  final double? lat;
  final double? lng;

  const RequestHomeAddress({
    this.id,
    this.label,
    this.lat,
    this.lng,
  });

  factory RequestHomeAddress.fromJson(Map<String, dynamic> json) =>
      RequestHomeAddress(
        id: _parseInt(json['id']),
        label: json['label']?.toString(),
        lat: _parseDouble(json['lat'] ?? json['latitude']),
        lng: _parseDouble(json['lng'] ?? json['longitude']),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (label != null) 'label': label,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      };
}

// ── التسعير الإجمالي للطلب ──
class RequestRootPricing {
  final double totalPrice;
  final double discountAmount;
  final double totalAmountAfterDiscount;

  const RequestRootPricing({
    required this.totalPrice,
    required this.discountAmount,
    required this.totalAmountAfterDiscount,
  });

  bool get hasDiscount => discountAmount > 0;

  String fmt(double v) =>
      v == v.toInt() ? '${v.toInt()} د.ل' : '${v.toStringAsFixed(2)} د.ل';

  String get formattedTotal => fmt(totalPrice);
  String get formattedDiscount => fmt(discountAmount);
  String get formattedAfterDiscount => fmt(totalAmountAfterDiscount);

  factory RequestRootPricing.fromJson(Map<String, dynamic> json) =>
      RequestRootPricing(
        totalPrice: _parseDouble(json['total_price']) ?? 0.0,
        discountAmount: _parseDouble(json['discount_amount']) ?? 0.0,
        totalAmountAfterDiscount:
            _parseDouble(json['total_amount_after_discount'] ??
                    json['total_price']) ??
                0.0,
      );

  Map<String, dynamic> toJson() => {
        'total_price': totalPrice,
        'discount_amount': discountAmount,
        'total_amount_after_discount': totalAmountAfterDiscount,
      };
}

// ── تسعير الطفل الواحد ──
class RequestChildPricing {
  final double priceBeforeDiscount;
  final double discountPercentage;
  final double discountAmount;
  final double priceAfterDiscount;

  const RequestChildPricing({
    required this.priceBeforeDiscount,
    required this.discountPercentage,
    required this.discountAmount,
    required this.priceAfterDiscount,
  });

  bool get hasDiscount => discountAmount > 0;

  String fmt(double v) =>
      v == v.toInt() ? '${v.toInt()} د.ل' : '${v.toStringAsFixed(2)} د.ل';

  String get formattedPriceAfterDiscount => fmt(priceAfterDiscount);
  String get formattedPriceBeforeDiscount => fmt(priceBeforeDiscount);

  factory RequestChildPricing.fromJson(Map<String, dynamic> json) =>
      RequestChildPricing(
        priceBeforeDiscount:
            _parseDouble(json['price_before_discount']) ?? 0.0,
        discountPercentage:
            _parseDouble(json['discount_percentage']) ?? 0.0,
        discountAmount: _parseDouble(json['discount_amount']) ?? 0.0,
        priceAfterDiscount:
            _parseDouble(json['price_after_discount']) ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'price_before_discount': priceBeforeDiscount,
        'discount_percentage': discountPercentage,
        'discount_amount': discountAmount,
        'price_after_discount': priceAfterDiscount,
      };
}

// ── مدرسة الطفل ──
class RequestChildSchool {
  final int? id;
  final String name;
  final double? lat;
  final double? lng;

  const RequestChildSchool({
    this.id,
    required this.name,
    this.lat,
    this.lng,
  });

  factory RequestChildSchool.fromJson(Map<String, dynamic> json) =>
      RequestChildSchool(
        id: _parseInt(json['id']),
        name: json['name']?.toString() ?? '',
        lat: _parseDouble(json['lat'] ?? json['latitude']),
        lng: _parseDouble(json['lng'] ?? json['longitude']),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      };
}

// ── الطفل ──
class RequestChild {
  final int childId;
  final String name;
  final String? photoUrl;
  final int? age;
  final String? gender;
  final String? grade;
  final String? gradeLabel;
  final RequestChildSchool school;
  final String? timing;
  final double? distanceKm;
  final String? medicalNotes;
  final RequestChildPricing? pricing;

  const RequestChild({
    required this.childId,
    required this.name,
    this.photoUrl,
    this.age,
    this.gender,
    this.grade,
    this.gradeLabel,
    required this.school,
    this.timing,
    this.distanceKm,
    this.medicalNotes,
    this.pricing,
  });

  bool get isFemale => gender == 'female';

  String get avatarInitials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return name[0];
  }

  String get gradeLabelDisplay =>
      gradeLabel ?? (grade != null ? 'الصف $grade' : '');

  factory RequestChild.fromJson(Map<String, dynamic> json) => RequestChild(
        childId: _parseInt(json['child_id'] ?? json['id']) ?? 0,
        name: json['name']?.toString() ?? '',
        photoUrl: json['photo_url']?.toString() ?? json['photo']?.toString(),
        age: _parseInt(json['age']),
        gender: json['gender']?.toString(),
        grade: json['grade']?.toString(),
        gradeLabel: json['grade_label']?.toString(),
        school: RequestChildSchool.fromJson(
            json['school'] as Map<String, dynamic>? ?? {}),
        timing: json['timing']?.toString(),
        distanceKm: _parseDouble(json['distance_km']),
        medicalNotes: json['medical_notes']?.toString(),
        pricing: json['pricing'] is Map
            ? RequestChildPricing.fromJson(
                Map<String, dynamic>.from(json['pricing'] as Map))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'child_id': childId,
        'name': name,
        if (photoUrl != null) 'photo_url': photoUrl,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
        if (grade != null) 'grade': grade,
        if (gradeLabel != null) 'grade_label': gradeLabel,
        'school': school.toJson(),
        if (timing != null) 'timing': timing,
        if (distanceKm != null) 'distance_km': distanceKm,
        if (medicalNotes != null) 'medical_notes': medicalNotes,
        if (pricing != null) 'pricing': pricing!.toJson(),
      };
}

// ─────────────────────────────────────────────
// Safe JSON parsing helpers
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
