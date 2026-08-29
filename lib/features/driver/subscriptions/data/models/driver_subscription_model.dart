import 'package:kids_transport/core/utils/subscription_enums.dart';
// نموذج الاشتراكات النشطة للسائق - GET /api/driver/active-subscriptions
// الفلاتر: active | pending | completed | cancelled

class LocationModel {
  final double latitude;
  final double longitude;
  final String? label;
  final String? address;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.label,
    this.address,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: _parseDouble(json['latitude'] ?? json['lat']) ?? 0.0,
      longitude: _parseDouble(json['longitude'] ?? json['lng']) ?? 0.0,
      label: json['label']?.toString() ?? json['name']?.toString(),
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'label': label,
        'address': address,
      };
}

class CoordinatesModel {
  final LocationModel? home;
  final LocationModel? school;

  CoordinatesModel({
    this.home,
    this.school,
  });

  factory CoordinatesModel.fromJson(Map<String, dynamic> json) {
    return CoordinatesModel(
      home: json['home'] is Map ? LocationModel.fromJson(Map<String, dynamic>.from(json['home'] as Map)) : null,
      school: json['school'] is Map ? LocationModel.fromJson(Map<String, dynamic>.from(json['school'] as Map)) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'home': home?.toJson(),
        'school': school?.toJson(),
      };
}

class ParentSubscriptionModel {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? avatarUrl;

  ParentSubscriptionModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.avatarUrl,
  });

  factory ParentSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return ParentSubscriptionModel(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? 'غير معروف',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      avatarUrl: json['avatar']?.toString() ?? json['avatar_url']?.toString() ?? json['photo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'avatar': avatarUrl,
      };
}

class ChildSubscriptionModel {
  final int id;
  final String? name;
  final String? firstName;
  final String? lastName;
  final int? age;
  final String? gender;
  final int? grade;
  final String? photoUrl;
  final String? notes;
  final String? school;
  final String? schoolAddress;

  ChildSubscriptionModel({
    required this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.age,
    this.gender,
    this.grade,
    this.photoUrl,
    this.notes,
    this.school,
    this.schoolAddress,
  });

  String get displayName => name ?? '${firstName ?? ''} ${lastName ?? ''}'.trim();

  String get schoolName => school ?? 'غير حدد';

  String get avatarInitials {
    final displayNameVal = displayName;
    if (displayNameVal.isEmpty) return '?';
    final parts = displayNameVal.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return displayNameVal[0];
  }

  factory ChildSubscriptionModel.fromJson(Map<String, dynamic> json) {
    final school = json['school'] as Map<String, dynamic>? ??
        json['School'] as Map<String, dynamic>?;
    // الملاحظات ترجع ككائن {"child_notes": "..."} وليس نصاً مباشراً
    final notesJson = json['notes'];
    final notesText = notesJson is Map
        ? notesJson['child_notes']?.toString()
        : notesJson?.toString();

    return ChildSubscriptionModel(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString(),
      firstName: json['first_name']?.toString() ?? json['firstName']?.toString(),
      lastName: json['last_name']?.toString() ?? json['lastName']?.toString(),
      age: _parseInt(json['age']),
      gender: json['gender']?.toString(),
      grade: _parseInt(json['grade']),
      photoUrl: json['photo_url']?.toString() ?? json['photoUrl']?.toString(),
      notes: notesText,
      school: school?['name']?.toString() ?? json['school']?.toString(),
      schoolAddress: school?['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'first_name': firstName,
        'last_name': lastName,
        'age': age,
        'gender': gender,
        'grade': grade,
        'photo_url': photoUrl,
        'notes': notes,
        'school': school,
      };
}

class DriverSubscriptionModel {
  final int id;
  final String status;
  final String? tripDirection;
  final String? timing;
  final LocationModel? pickupLocation; // منزل الطفل
  final LocationModel? dropoffLocation; // المدرسة
  final CoordinatesModel? coordinates;
  final ParentSubscriptionModel parent;
  final ChildSubscriptionModel child;
  final String createdAt;
  final String? subscriptionType;

  // ── المالية (بديل contract غير الموجود في الرد الفعلي) ──
  final double? tripPrice; // السعر الأساسي قبل الخصم
  final double? pricePerChild; // السعر اللي دفعه ولي الأمر (بعد الخصم)
  final double? platformCommission; // عمولة المنصة
  final double? driverNetPrice; // صافي مستحقات السائق
  final String? startDate;
  final String? endDate;
  final int? workingDaysCount;

  DriverSubscriptionModel({
    required this.id,
    required this.status,
    this.tripDirection,
    this.timing,
    this.pickupLocation,
    this.dropoffLocation,
    this.coordinates,
    required this.parent,
    required this.child,
    required this.createdAt,
    this.subscriptionType,
    this.tripPrice,
    this.pricePerChild,
    this.platformCommission,
    this.driverNetPrice,
    this.startDate,
    this.endDate,
    this.workingDaysCount,
  });

  String get statusDisplayLabel {
    switch (status.toLowerCase()) {
      case 'active':
        return 'نشط';
      case 'accepted':
        return 'مقبول';
      case 'pending':
      case 'pending_start':
        return 'معلق';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  String get subscriptionTypeDisplayLabel =>
      SubscriptionEnums.typeLabel(subscriptionType);

  String get tripDirectionLabel => SubscriptionEnums.directionLabel(tripDirection);
  String get timingLabel => SubscriptionEnums.timingLabel(timing);

  String? get pickupLabel => pickupLocation?.address ?? pickupLocation?.label;
  String? get dropoffLabel => dropoffLocation?.label;

  factory DriverSubscriptionModel.fromJson(Map<String, dynamic> json) {
    final childJson = json['child'] as Map<String, dynamic>? ?? {};
    final pricing = childJson['pricing'] as Map<String, dynamic>? ?? {};
    final period = childJson['subscription_period'] as Map<String, dynamic>? ?? {};
    final tripDetails = childJson['trip_details'] as Map<String, dynamic>? ?? {};
    final home = childJson['home'] as Map<String, dynamic>? ??
        childJson['Home'] as Map<String, dynamic>?;
    final school = childJson['school'] as Map<String, dynamic>? ??
        childJson['School'] as Map<String, dynamic>?;

    // status ترجع ككائن {"value": "accepted"} وأحياناً كنص مباشر
    final statusJson = json['status'];
    final statusValue = statusJson is Map
        ? statusJson['value']?.toString()
        : statusJson?.toString();

    return DriverSubscriptionModel(
      id: _parseInt(json['active_subscription_id'] ?? json['id'] ?? json['subscription_id']) ?? 0,
      status: statusValue ?? 'active',
      tripDirection: tripDetails['trip_direction']?.toString(),
      timing: tripDetails['timing']?.toString(),
      pickupLocation: home != null ? LocationModel.fromJson(home) : null,
      dropoffLocation: school != null ? LocationModel.fromJson(school) : null,
      coordinates: CoordinatesModel(
        home: home != null ? LocationModel.fromJson(home) : null,
        school: school != null ? LocationModel.fromJson(school) : null,
      ),
      parent: json['parent'] is Map
          ? ParentSubscriptionModel.fromJson(Map<String, dynamic>.from(json['parent'] as Map))
          : ParentSubscriptionModel(id: 0, name: 'غير معروف'),
      child: ChildSubscriptionModel.fromJson(childJson),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
      subscriptionType: tripDetails['subscription_type']?.toString(),
      tripPrice: _parseDouble(pricing['trip_price']),
      pricePerChild: _parseDouble(pricing['price_per_child']),
      platformCommission: _parseDouble(pricing['platform_commission']),
      driverNetPrice: _parseDouble(pricing['driver_net_price']) ?? _parseDouble(json['driver_net_total']),
      startDate: period['start_date']?.toString(),
      endDate: period['end_date']?.toString(),
      workingDaysCount: _parseInt(period['working_days_count']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'trip_direction': tripDirection,
        'timing': timing,
        'pickup_location': pickupLocation?.toJson(),
        'dropoff_location': dropoffLocation?.toJson(),
        'coordinates': coordinates?.toJson(),
        'parent': parent.toJson(),
        'child': child.toJson(),
        'created_at': createdAt,
        'subscription_type': subscriptionType,
      };
}

// ─────────────────────────────────────────────
// Private helper functions for safe JSON parsing
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
