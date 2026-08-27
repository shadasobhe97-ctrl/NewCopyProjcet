import 'package:kids_transport/core/utils/subscription_enums.dart';

import 'subscription_location_model.dart';

// نموذج طلب الاشتراك - GET /api/parent/requests/{id}
class RequestModel {
  final int id;
  final String status;
  final String startDate;
  final int workingDaysCount;
  final double totalAmount;
  final int childrenCount;
  final String createdAt;
  final RequestDriver driver;
  final List<RequestChild> children;
  
  final String? statusAr;
  final String? rejectionReason;
  final String? notes;

  const RequestModel({
    required this.id,
    required this.status,
    required this.startDate,
    required this.workingDaysCount,
    required this.totalAmount,
    required this.childrenCount,
    required this.createdAt,
    required this.driver,
    required this.children,
    this.statusAr,
    this.rejectionReason,
    this.notes,
  });

  String get childrenNames {
    return children.map((c) => c.name).join('، ');
  }

  String get statusDisplayLabel {
    if (statusAr != null && statusAr!.isNotEmpty) return statusAr!;
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'approved':
        return 'تمت الموافقة';
      case 'rejected':
        return 'مرفوض';
      case 'pending':
        return 'قيد الانتظار';
      case 'cancelled':
        return 'ملغي';
      case 'active':
        return 'نشط';
      case 'completed':
        return 'مكتمل';
      default:
        return 'غير محدد';
    }
  }

  String get formattedPrice {
    if (totalAmount == totalAmount.toInt()) {
      return '${totalAmount.toInt()} د.ل';
    }
    return '${totalAmount.toStringAsFixed(2)} د.ل';
  }

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    final childrenList = (json['children'] as List<dynamic>? ?? [])
        .map((e) => RequestChild.fromJson(e as Map<String, dynamic>))
        .toList();

    return RequestModel(
      id: _parseInt(json['id']) ?? 0,
      status: json['status']?.toString() ?? 'pending',
      startDate: json['start_date']?.toString() ??
          (childrenList.isNotEmpty ? childrenList.first.subscription.startDate : ''),
      workingDaysCount: _parseInt(json['working_days_count']) ??
          (childrenList.isNotEmpty
              ? childrenList.first.subscription.workingDaysCount
              : 0),
      totalAmount: _parseDouble(json['total_amount'] ?? json['total_price']) ?? 0.0,
      childrenCount: _parseInt(json['children_count']) ?? childrenList.length,
      createdAt: json['created_at']?.toString() ?? '',
      driver: RequestDriver.fromJson(json['driver'] as Map<String, dynamic>? ?? {}),
      children: childrenList,
      statusAr: json['status_ar']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'start_date': startDate,
        'working_days_count': workingDaysCount,
        'total_amount': totalAmount,
        'children_count': childrenCount,
        'created_at': createdAt,
        'driver': driver.toJson(),
        'children': children.map((c) => c.toJson()).toList(),
        if (statusAr != null) 'status_ar': statusAr,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
        if (notes != null) 'notes': notes,
      };
}

// ── السائق ──
class RequestDriver {
  final int id;
  final String name;
  final String? phone;

  const RequestDriver({
    required this.id,
    required this.name,
    this.phone,
  });

  factory RequestDriver.fromJson(Map<String, dynamic> json) => RequestDriver(
        id: _parseInt(json['id']) ?? 0,
        name: json['name']?.toString() ?? json['full_name']?.toString() ?? '',
        phone: json['phone']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (phone != null) 'phone': phone,
      };
}

// ── المدرسة ──
class RequestSchool {
  final int id;
  final String name;
  final String? address;

  const RequestSchool({
    required this.id,
    required this.name,
    this.address,
  });

  factory RequestSchool.fromJson(Map<String, dynamic> json) => RequestSchool(
        id: _parseInt(json['id']) ?? 0,
        name: json['name']?.toString() ?? '',
        address: json['address']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (address != null) 'address': address,
      };
}

// ── المنزل ──
class RequestHome {
  final String address;

  const RequestHome({
    required this.address,
  });

  factory RequestHome.fromJson(Map<String, dynamic> json) => RequestHome(
        address: json['address']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'address': address,
      };
}

// ── اشتراك الطفل ──
class RequestChildSubscription {
  final String type;
  final String tripType;
  final String timing;
  final String startDate;
  final String? endDate;
  final int workingDaysCount;
  /// إجمالي اشتراك الطفل للفترة كاملة (سعر الرحلة × عدد أيام العمل)
  final double? pricePerChild;
  final double? distanceKm;

  /// سعر الرحلة الواحدة
  final double? tripPrice;

  const RequestChildSubscription({
    required this.type,
    required this.tripType,
    this.timing = '',
    required this.startDate,
    this.endDate,
    required this.workingDaysCount,
    this.pricePerChild,
    this.distanceKm,
    this.tripPrice,
  });

  /// يوم واحد | عدة أيام — لا توجد اشتراكات شهرية/أسبوعية في العقد.
  String get typeDisplayLabel =>
      type.isEmpty ? 'غير متوفر' : SubscriptionEnums.typeLabel(type);

  String get tripTypeDisplayLabel =>
      tripType.isEmpty ? 'غير متوفر' : SubscriptionEnums.directionLabel(tripType);

  String get timingDisplayLabel =>
      timing.isEmpty ? 'غير متوفر' : SubscriptionEnums.timingLabel(timing);

  factory RequestChildSubscription.fromJson(Map<String, dynamic> json) =>
      RequestChildSubscription(
        type: json['type']?.toString() ?? json['subscription_type']?.toString() ?? '',
        tripType: json['trip_type']?.toString() ?? json['trip_direction']?.toString() ?? '',
        timing: json['timing']?.toString() ?? '',
        startDate: json['start_date']?.toString() ?? '',
        endDate: json['end_date']?.toString(),
        workingDaysCount: _parseInt(json['working_days_count']) ?? 0,
        pricePerChild: _parseDouble(json['price_per_child']),
        distanceKm: _parseDouble(json['distance_km']),
        tripPrice: _parseDouble(json['trip_price']),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'trip_type': tripType,
        if (timing.isNotEmpty) 'timing': timing,
        'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        'working_days_count': workingDaysCount,
        if (pricePerChild != null) 'price_per_child': pricePerChild,
        if (distanceKm != null) 'distance_km': distanceKm,
        if (tripPrice != null) 'trip_price': tripPrice,
      };
}

// ── الطفل ──
class RequestChild {
  final int id;
  final String name;
  final double price;
  final String? gender;
  final int? age;
  final String? photoUrl;
  final RequestSchool school;
  final RequestHome home;
  final RequestChildSubscription subscription;
  final SubscriptionLocationModel? pickupLocation;
  final SubscriptionLocationModel? dropoffLocation;

  const RequestChild({
    required this.id,
    required this.name,
    required this.price,
    this.gender,
    this.age,
    this.photoUrl,
    required this.school,
    required this.home,
    required this.subscription,
    this.pickupLocation,
    this.dropoffLocation,
  });

  /// اسم المدرسة: من كائن school إن وُجد، وإلا من نقطة الوصول (School/dropoff_location)
  String get schoolName {
    if (school.name.isNotEmpty) return school.name;
    if (dropoffLocation?.hasName ?? false) return dropoffLocation!.name!.trim();
    return '';
  }

  String get avatarInitials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return name[0];
  }

  factory RequestChild.fromJson(Map<String, dynamic> json) {
    return RequestChild(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      price: _parseDouble(json['price'] ??
              json['price_per_child'] ??
              (json['details'] is Map
                  ? (json['details'] as Map)['price_per_child']
                  : null)) ??
          0.0,
      gender: json['gender']?.toString(),
      age: _parseInt(json['age']),
      photoUrl: json['photo_url']?.toString() ?? json['photo']?.toString(),
      school: RequestSchool.fromJson(json['school'] as Map<String, dynamic>? ?? {}),
      home: RequestHome.fromJson(json['home'] as Map<String, dynamic>? ?? {}),
      subscription: RequestChildSubscription.fromJson(
        (json['subscription'] ?? json['details']) as Map<String, dynamic>? ?? {},
      ),
      // الخادم يرسلها أحياناً باسم pickup_location/dropoff_location
      // وأحياناً باسم Home/School — ندعم الشكلين
      pickupLocation: _location(json['pickup_location'] ?? json['Home'] ?? json['home']),
      dropoffLocation: _location(json['dropoff_location'] ?? json['School'] ?? json['school_location']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        if (gender != null) 'gender': gender,
        if (age != null) 'age': age,
        if (photoUrl != null) 'photo_url': photoUrl,
        'school': school.toJson(),
        'home': home.toJson(),
        'subscription': subscription.toJson(),
        if (pickupLocation != null) 'pickup_location': pickupLocation!.toJson(),
        if (dropoffLocation != null) 'dropoff_location': dropoffLocation!.toJson(),
      };
}

SubscriptionLocationModel? _location(dynamic raw) {
  if (raw is! Map) return null;
  return SubscriptionLocationModel.fromJson(Map<String, dynamic>.from(raw));
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
