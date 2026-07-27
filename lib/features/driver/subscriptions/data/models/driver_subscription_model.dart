// نموذج الاشتراكات النشطة للسائق - GET /api/driver/active-subscriptions
// الفلاتر: active | pending | completed | cancelled

class LocationModel {
  final double latitude;
  final double longitude;
  final String? label;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.label,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: _parseDouble(json['latitude']) ?? 0.0,
      longitude: _parseDouble(json['longitude']) ?? 0.0,
      label: json['label']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'label': label,
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

  ParentSubscriptionModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
  });

  factory ParentSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return ParentSubscriptionModel(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? 'غير معروف',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
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
    return ChildSubscriptionModel(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString(),
      firstName: json['first_name']?.toString() ?? json['firstName']?.toString(),
      lastName: json['last_name']?.toString() ?? json['lastName']?.toString(),
      age: _parseInt(json['age']),
      gender: json['gender']?.toString(),
      grade: _parseInt(json['grade']),
      photoUrl: json['photo_url']?.toString() ?? json['photoUrl']?.toString(),
      notes: json['notes']?.toString(),
      school: json['school']?.toString(),
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

class ContractModel {
  final int id;
  final String contractNumber;
  final String startDate;
  final String endDate;
  final int totalWorkingDays;
  final double totalPrice;
  final String status;

  ContractModel({
    required this.id,
    required this.contractNumber,
    required this.startDate,
    required this.endDate,
    required this.totalWorkingDays,
    required this.totalPrice,
    required this.status,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: _parseInt(json['id']) ?? 0,
      contractNumber: json['contract_number']?.toString() ?? json['contractNumber']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? json['startDate']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? json['endDate']?.toString() ?? '',
      totalWorkingDays: _parseInt(json['total_working_days'] ?? json['totalWorkingDays']) ?? 0,
      totalPrice: _parseDouble(json['total_price'] ?? json['totalPrice']) ?? 0.0,
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'contract_number': contractNumber,
        'start_date': startDate,
        'end_date': endDate,
        'total_working_days': totalWorkingDays,
        'total_price': totalPrice,
        'status': status,
      };
}

class DriverSubscriptionModel {
  final int id;
  final String status;
  final String? pickupTime;
  final String? dropoffTime;
  final String tripType;
  final LocationModel? pickupLocation;
  final LocationModel? dropoffLocation;
  final CoordinatesModel? coordinates;
  final ParentSubscriptionModel parent;
  final ChildSubscriptionModel child;
  final ContractModel? contract;
  final String createdAt;

  DriverSubscriptionModel({
    required this.id,
    required this.status,
    this.pickupTime,
    this.dropoffTime,
    required this.tripType,
    this.pickupLocation,
    this.dropoffLocation,
    this.coordinates,
    required this.parent,
    required this.child,
    this.contract,
    required this.createdAt,
  });

  String get statusDisplayLabel {
    switch (status.toLowerCase()) {
      case 'active':
        return 'نشط';
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

  String? get pickupLabel => pickupLocation?.label;
  String? get dropoffLabel => dropoffLocation?.label;

  factory DriverSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return DriverSubscriptionModel(
      id: _parseInt(json['id']) ?? 0,
      status: json['status']?.toString() ?? 'active',
      pickupTime: json['pickup_time']?.toString() ?? json['pickupTime']?.toString(),
      dropoffTime: json['dropoff_time']?.toString() ?? json['dropoffTime']?.toString(),
      tripType: json['trip_type']?.toString() ?? json['tripType']?.toString() ?? 'both',
      pickupLocation: json['pickup_location'] is Map
          ? LocationModel.fromJson(Map<String, dynamic>.from(json['pickup_location'] as Map))
          : (json['pickupLocation'] is Map
              ? LocationModel.fromJson(Map<String, dynamic>.from(json['pickupLocation'] as Map))
              : null),
      dropoffLocation: json['dropoff_location'] is Map
          ? LocationModel.fromJson(Map<String, dynamic>.from(json['dropoff_location'] as Map))
          : (json['dropoffLocation'] is Map
              ? LocationModel.fromJson(Map<String, dynamic>.from(json['dropoffLocation'] as Map))
              : null),
      coordinates: json['coordinates'] is Map
          ? CoordinatesModel.fromJson(Map<String, dynamic>.from(json['coordinates'] as Map))
          : null,
      parent: json['parent'] is Map
          ? ParentSubscriptionModel.fromJson(Map<String, dynamic>.from(json['parent'] as Map))
          : ParentSubscriptionModel(id: 0, name: 'غير معروف'),
      child: json['child'] is Map
          ? ChildSubscriptionModel.fromJson(Map<String, dynamic>.from(json['child'] as Map))
          : ChildSubscriptionModel(id: 0),
      contract: json['contract'] is Map
          ? ContractModel.fromJson(Map<String, dynamic>.from(json['contract'] as Map))
          : null,
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'pickup_time': pickupTime,
        'dropoff_time': dropoffTime,
        'trip_type': tripType,
        'pickup_location': pickupLocation?.toJson(),
        'dropoff_location': dropoffLocation?.toJson(),
        'coordinates': coordinates?.toJson(),
        'parent': parent.toJson(),
        'child': child.toJson(),
        'contract': contract?.toJson(),
        'created_at': createdAt,
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
