// نموذج طلب الاشتراك الجديد - GET /api/parent/requests/{id}
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
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'pending':
        return 'قيد الانتظار';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
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
      startDate: json['start_date']?.toString() ?? '',
      workingDaysCount: _parseInt(json['working_days_count']) ?? 0,
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
  final String startDate;
  final String? endDate;
  final int workingDaysCount;

  const RequestChildSubscription({
    required this.type,
    required this.tripType,
    required this.startDate,
    this.endDate,
    required this.workingDaysCount,
  });

  factory RequestChildSubscription.fromJson(Map<String, dynamic> json) =>
      RequestChildSubscription(
        type: json['type']?.toString() ?? '',
        tripType: json['trip_type']?.toString() ?? '',
        startDate: json['start_date']?.toString() ?? '',
        endDate: json['end_date']?.toString(),
        workingDaysCount: _parseInt(json['working_days_count']) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'trip_type': tripType,
        'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        'working_days_count': workingDaysCount,
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
  });

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
      price: _parseDouble(json['price']) ?? 0.0,
      gender: json['gender']?.toString(),
      age: _parseInt(json['age']),
      photoUrl: json['photo_url']?.toString(),
      school: RequestSchool.fromJson(json['school'] as Map<String, dynamic>? ?? {}),
      home: RequestHome.fromJson(json['home'] as Map<String, dynamic>? ?? {}),
      subscription: RequestChildSubscription.fromJson(json['subscription'] as Map<String, dynamic>? ?? {}),
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
