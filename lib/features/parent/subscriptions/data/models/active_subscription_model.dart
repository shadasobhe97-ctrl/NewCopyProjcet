import 'package:kids_transport/core/utils/subscription_enums.dart';
import 'request_model.dart'
    show RequestVehicle, RequestSubscriptionInfo, RequestHomeAddress, RequestChildPricing, RequestChildSchool;

/// نموذج الاشتراك النشط — GET /api/parent/active-subscriptions
/// كل اشتراك نشط يمثل طفلاً واحداً، لكن النموذج يدعم أكثر من طفل مستقبلاً
class ActiveSubscriptionModel {
  final int id; // active_subscription_id
  final String status;
  final String? statusLabel;
  final ActiveDriver driver;
  final RequestSubscriptionInfo subscription; // مشترك
  final RequestHomeAddress? homeAddress;
  final List<ActiveChild> children; // طفل واحد حالياً، قابل للتوسع
  final String? notes;
  final String createdAt;
  final String? updatedAt;
  final int? routeId;
  final String? pickupTime;
  final String? dropoffTime;

  const ActiveSubscriptionModel({
    required this.id,
    required this.status,
    this.statusLabel,
    required this.driver,
    required this.subscription,
    this.homeAddress,
    required this.children,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.routeId,
    this.pickupTime,
    this.dropoffTime,
  });

  String get statusDisplayLabel =>
      SubscriptionEnums.statusLabel(status, fallbackLabel: statusLabel);

  /// الطفل الأول (للعرض في الكروت البسيطة)
  ActiveChild? get firstChild => children.isNotEmpty ? children.first : null;

  String get formattedPrice {
    final price = firstChild?.pricing?.priceAfterDiscount ?? 0.0;
    if (price == price.toInt()) return '${price.toInt()} دينار';
    return '${price.toStringAsFixed(2)} دينار';
  }

  factory ActiveSubscriptionModel.fromJson(Map<String, dynamic> json) {
    // الباك يبعت child (مفرد) — نحوّله لقائمة لدعم المستقبل
    final childrenList = <ActiveChild>[];
    final childJson = json['child'] as Map<String, dynamic>?;
    final childrenJson = json['children'] as List<dynamic>?;
    if (childrenJson != null) {
      childrenList.addAll(childrenJson
          .map((e) => ActiveChild.fromJson(e as Map<String, dynamic>))
          .toList());
    } else if (childJson != null) {
      childrenList.add(ActiveChild.fromJson(childJson));
    }

    return ActiveSubscriptionModel(
      id: _parseInt(json['active_subscription_id'] ?? json['id']) ?? 0,
      status: json['status']?.toString() ?? 'active',
      statusLabel:
          json['status_label']?.toString() ?? json['statusLabel']?.toString(),
      driver: ActiveDriver.fromJson(
          json['driver'] as Map<String, dynamic>? ?? {}),
      subscription: RequestSubscriptionInfo.fromJson(
          json['subscription'] as Map<String, dynamic>? ?? {}),
      homeAddress: json['home_address'] is Map
          ? RequestHomeAddress.fromJson(
              Map<String, dynamic>.from(json['home_address'] as Map))
          : null,
      children: childrenList,
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString() ??
          json['createdAt']?.toString() ??
          '',
      updatedAt: json['updated_at']?.toString(),
      routeId: _parseInt(json['route_id']),
      pickupTime: json['pickup_time']?.toString(),
      dropoffTime: json['dropoff_time']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'active_subscription_id': id,
        'status': status,
        if (statusLabel != null) 'status_label': statusLabel,
        'driver': driver.toJson(),
        'subscription': subscription.toJson(),
        if (homeAddress != null) 'home_address': homeAddress!.toJson(),
        'children': children.map((c) => c.toJson()).toList(),
        if (notes != null) 'notes': notes,
        'created_at': createdAt,
        if (routeId != null) 'route_id': routeId,
        if (pickupTime != null) 'pickup_time': pickupTime,
        if (dropoffTime != null) 'dropoff_time': dropoffTime,
      };
}

// ── السائق ──
class ActiveDriver {
  final int id;
  final String name;
  final String? phone;
  final String? alternativePhone;
  final String? gender;
  final String? avatarUrl;
  final RequestVehicle? vehicle;

  const ActiveDriver({
    required this.id,
    required this.name,
    this.phone,
    this.alternativePhone,
    this.gender,
    this.avatarUrl,
    this.vehicle,
  });

  bool get isFemale => gender == 'female';

  factory ActiveDriver.fromJson(Map<String, dynamic> json) => ActiveDriver(
        id: _parseInt(json['id']) ?? 0,
        name: json['name']?.toString() ?? '',
        phone: json['phone']?.toString(),
        alternativePhone: json['alternative_phone']?.toString(),
        gender: json['gender']?.toString(),
        avatarUrl: json['photo_url']?.toString() ??
            json['photo']?.toString() ??
            json['avatar_url']?.toString() ??
            json['avatar']?.toString(),
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
        if (avatarUrl != null) 'photo_url': avatarUrl,
        if (vehicle != null) 'vehicle': vehicle!.toJson(),
      };
}

// ── الطفل في الاشتراك النشط ──
class ActiveChild {
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

  const ActiveChild({
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

  String get hasMedicalNotes =>
      (medicalNotes != null && medicalNotes!.trim().isNotEmpty &&
              medicalNotes != 'لا يوجد')
          ? medicalNotes!
          : '';

  factory ActiveChild.fromJson(Map<String, dynamic> json) => ActiveChild(
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
