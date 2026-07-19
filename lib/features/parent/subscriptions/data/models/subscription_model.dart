// نموذج الاشتراك - GET /api/parent/subscriptions
// Response fields: id, subscription_type, direction, timing, start_date, end_date,
// total_price, status, status_ar, pickup_time, dropoff_time, created_at,
// driver{id,name,phone}, school{id,name}, children[{id,name,school_name,price_per_child}],
// contract{id,contract_number,pdf_url}?

class SubscriptionModel {
  final int id;
  final String subscriptionType; // monthly | weekly | daily
  final String direction;        // both | to_school | from_school
  final String timing;           // MORNING | AFTERNOON
  final String startDate;
  final String endDate;
  final double totalPrice;
  final String status;           // pending | accepted | rejected | cancelled
  final String? statusAr;
  final String? pickupTime;
  final String? dropoffTime;
  final String createdAt;
  final SubDriver driver;
  final SubSchool school;
  final List<SubChild> children;
  final SubContract? contract;
  final double? pricePerChild;
  final String? notes;
  final String? rejectionReason;

  const SubscriptionModel({
    required this.id,
    required this.subscriptionType,
    required this.direction,
    required this.timing,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    this.statusAr,
    this.pickupTime,
    this.dropoffTime,
    required this.createdAt,
    required this.driver,
    required this.school,
    required this.children,
    this.contract,
    this.pricePerChild,
    this.notes,
    this.rejectionReason,
  });

  int get childrenCount => children.length;

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

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: _parseInt(json['id']) ?? 0,
      subscriptionType: json['subscription_type']?.toString() ?? 'monthly',
      direction: json['direction']?.toString() ?? '',
      timing: json['timing']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      statusAr: json['status_ar']?.toString(),
      pickupTime: json['pickup_time']?.toString(),
      dropoffTime: json['dropoff_time']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      driver: SubDriver.fromJson(
        json['driver'] as Map<String, dynamic>? ?? {},
      ),
      school: SubSchool.fromJson(
        json['school'] as Map<String, dynamic>? ?? {},
      ),
      children: (json['children'] as List<dynamic>? ?? [])
          .map((e) => SubChild.fromJson(e as Map<String, dynamic>))
          .toList(),
      contract: json['contract'] is Map
          ? SubContract.fromJson(
              Map<String, dynamic>.from(json['contract'] as Map))
          : null,
      pricePerChild: (json['price_per_child'] as num?)?.toDouble(),
      notes: json['notes']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
    );
  }

  static int? _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subscription_type': subscriptionType,
        'direction': direction,
        'timing': timing,
        'start_date': startDate,
        'end_date': endDate,
        'total_price': totalPrice,
        'status': status,
        if (statusAr != null) 'status_ar': statusAr,
        if (pickupTime != null) 'pickup_time': pickupTime,
        if (dropoffTime != null) 'dropoff_time': dropoffTime,
        'created_at': createdAt,
        'driver': driver.toJson(),
        'school': school.toJson(),
        'children': children.map((c) => c.toJson()).toList(),
        if (contract != null) 'contract': contract!.toJson(),
        if (pricePerChild != null) 'price_per_child': pricePerChild,
        if (notes != null) 'notes': notes,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      };
}

// ── السائق ──
class SubDriverUser {
  final String fullName;
  final String? avatarUrl;

  const SubDriverUser({required this.fullName, this.avatarUrl});

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };
}

class SubDriver {
  final int id;
  final String name;
  final String? phone;
  final double rating;
  final int? tripCount;
  final int? subscriptionCount;
  final String? gender;

  const SubDriver({
    required this.id,
    required this.name,
    this.phone,
    this.rating = 5.0,
    this.tripCount,
    this.subscriptionCount,
    this.gender,
  });

  SubDriverUser get user => SubDriverUser(fullName: name);

  factory SubDriver.fromJson(Map<String, dynamic> json) => SubDriver(
        id: json['id'] as int? ?? 0,
        name: json['name']?.toString() ?? json['full_name']?.toString() ?? '',
        phone: json['phone']?.toString(),
        rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
        tripCount: json['trip_count'] as int? ?? json['trips_count'] as int?,
        subscriptionCount: json['subscription_count'] as int? ?? json['subscriptions_count'] as int?,
        gender: json['gender']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (phone != null) 'phone': phone,
        'rating': rating,
        if (tripCount != null) 'trip_count': tripCount,
        if (subscriptionCount != null) 'subscription_count': subscriptionCount,
        if (gender != null) 'gender': gender,
      };
}

// ── المدرسة ──
class SubSchool {
  final int id;
  final String name;
  final String? address;

  const SubSchool({required this.id, required this.name, this.address});

  factory SubSchool.fromJson(Map<String, dynamic> json) => SubSchool(
        id: json['id'] as int? ?? 0,
        name: json['name']?.toString() ?? '',
        address: json['address']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (address != null) 'address': address,
      };
}

// ── الطفل ──
class SubChild {
  final int? id;
  final String name;
  final String? schoolName;
  final double? pricePerChild;
  final String? photoUrl;
  final String grade;
  final SubSchool school;

  const SubChild({
    this.id,
    required this.name,
    this.schoolName,
    this.pricePerChild,
    this.photoUrl,
    required this.grade,
    required this.school,
  });

  String get fullName => name;

  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    return parts.length > 1
        ? '${parts[0][0]}${parts[1][0]}'
        : parts[0][0];
  }

  factory SubChild.fromJson(Map<String, dynamic> json) => SubChild(
        id: json['id'] as int?,
        name: json['name']?.toString() ?? json['full_name']?.toString() ?? '',
        schoolName: json['school_name']?.toString() ?? json['school']?['name']?.toString(),
        pricePerChild: (json['price_per_child'] as num?)?.toDouble(),
        photoUrl: json['photo_url']?.toString() ?? json['image']?.toString(),
        grade: json['grade']?.toString() ?? 'ابتدائي',
        school: SubSchool.fromJson(json['school'] as Map<String, dynamic>? ?? {
          'name': json['school_name']?.toString() ?? '',
        }),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        if (schoolName != null) 'school_name': schoolName,
        if (pricePerChild != null) 'price_per_child': pricePerChild,
        if (photoUrl != null) 'photo_url': photoUrl,
        'grade': grade,
        'school': school.toJson(),
      };
}

// ── العقد ──
class SubContract {
  final int id;
  final String contractNumber;
  final String? pdfUrl;

  const SubContract({
    required this.id,
    required this.contractNumber,
    this.pdfUrl,
  });

  factory SubContract.fromJson(Map<String, dynamic> json) => SubContract(
        id: json['id'] as int? ?? 0,
        contractNumber: json['contract_number']?.toString() ?? '',
        pdfUrl: json['pdf_url']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'contract_number': contractNumber,
        if (pdfUrl != null) 'pdf_url': pdfUrl,
      };
}

// ── أسماء مستعارة للتوافق مع الملفات القديمة ──
typedef SubscriptionDriver = SubDriver;
typedef SubscriptionChild = SubChild;
typedef SubscriptionSchool = SubSchool;
typedef SubscriptionUser = SubDriverUser;
