class DriverSearchModel {
  final DriverModelInfo driver;
  final VehicleModelInfo vehicle;
  final List<WorkingZoneModelInfo> workingZones;
  final PricingModelInfo pricing;
  final List<BreakdownModelInfo> breakdown;

  DriverSearchModel({
    required this.driver,
    required this.vehicle,
    required this.workingZones,
    required this.pricing,
    required this.breakdown,
  });

  // Getters to maintain backward compatibility with existing UI
  String get id => driver.id.toString();
  String get fullName => driver.fullName;
  String? get photoUrl => driver.avatarUrl;
  String get gender => driver.gender;
  double get rating => driver.rating;
  int get reviewsCount => driver.completedTrips; // Or completion count
  double get price => pricing.totalPrice;
  String get vehicleType => '${vehicle.brand} ${vehicle.model}';
  int get totalSeats => vehicle.capacityManual;
  int get availableSeats => vehicle.capacityManual - pricing.childrenCount;
  List<String> get serviceZones => workingZones.map((z) => z.name).toList();
  String get preferredTimeSlot => driver.shift;

  String? get phoneNumber => driver.phoneNumber;
  String? get alternativePhone => driver.alternativePhone;
  bool get isLicenseVerified => driver.status == 'active';
  bool get isCriminalRecordVerified => driver.status == 'active';
  bool get hasAc => vehicle.hasAc;
  int get completedTrips => driver.completedTrips;
  String? get plateNumber => vehicle.plateNumber;
  int? get vehicleYear => vehicle.year;
  String? get vehicleColor => vehicle.color;
  String? get status => driver.status;

  factory DriverSearchModel.fromJson(Map<String, dynamic> json) {
    return DriverSearchModel(
      driver: DriverModelInfo.fromJson(json['driver'] ?? {}),
      vehicle: VehicleModelInfo.fromJson(json['vehicle'] ?? {}),
      workingZones: (json['working_zones'] as List<dynamic>?)
              ?.map((e) => WorkingZoneModelInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pricing: PricingModelInfo.fromJson(json['pricing'] ?? {}),
      breakdown: (json['breakdown'] as List<dynamic>?)
              ?.map((e) => BreakdownModelInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DriverModelInfo {
  final int id;
  final String fullName;
  final String? phoneNumber;
  final String? alternativePhone;
  final String? avatarUrl;
  final String gender;
  final String? acceptedGender;
  final String shift;
  final double rating;
  final int completedTrips;
  final String status;

  DriverModelInfo({
    required this.id,
    required this.fullName,
    this.phoneNumber,
    this.alternativePhone,
    this.avatarUrl,
    required this.gender,
    this.acceptedGender,
    required this.shift,
    required this.rating,
    required this.completedTrips,
    required this.status,
  });

  factory DriverModelInfo.fromJson(Map<String, dynamic> json) {
    return DriverModelInfo(
      id: _readInt(json['id']),
      fullName: json['full_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString(),
      alternativePhone: json['alternative_phone']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      gender: json['gender']?.toString() ?? 'MALE',
      acceptedGender: json['accepted_gender']?.toString(),
      shift: json['shift']?.toString() ?? 'BOTH',
      rating: _readDouble(json['rating']),
      completedTrips: _readInt(json['completed_trips']),
      status: json['status']?.toString() ?? 'inactive',
    );
  }
}

class VehicleModelInfo {
  final String brand;
  final String model;
  final int year;
  final String color;
  final String type;
  final bool hasAc;
  final int capacityManual;
  final String plateNumber;

  VehicleModelInfo({
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.type,
    required this.hasAc,
    required this.capacityManual,
    required this.plateNumber,
  });

  factory VehicleModelInfo.fromJson(Map<String, dynamic> json) {
    return VehicleModelInfo(
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      year: _readInt(json['year']),
      color: json['color']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      hasAc: _readBool(json['has_ac']),
      capacityManual: _readInt(json['capacity_manual']),
      plateNumber: json['plate_number']?.toString() ?? '',
    );
  }
}

class WorkingZoneModelInfo {
  final int id;
  final String name;

  WorkingZoneModelInfo({
    required this.id,
    required this.name,
  });

  factory WorkingZoneModelInfo.fromJson(Map<String, dynamic> json) {
    return WorkingZoneModelInfo(
      id: _readInt(json['id']),
      name: json['name']?.toString() ?? '',
    );
  }
}

class PricingModelInfo {
  final double totalPrice;
  final int totalPriceRaw;
  final bool hasAc;
  final double pricePerKm;
  final int childrenCount;

  PricingModelInfo({
    required this.totalPrice,
    required this.totalPriceRaw,
    required this.hasAc,
    required this.pricePerKm,
    required this.childrenCount,
  });

  factory PricingModelInfo.fromJson(Map<String, dynamic> json) {
    return PricingModelInfo(
      totalPrice: _readDouble(json['total_price']),
      totalPriceRaw: _readInt(json['total_price_raw']),
      hasAc: _readBool(json['has_ac']),
      pricePerKm: _readDouble(json['price_per_km']),
      childrenCount: _readInt(json['children_count']),
    );
  }
}

class BreakdownModelInfo {
  final int childId;
  final String childName;
  final String schoolName;
  final double distanceKm;
  final double pricePerKm;
  final String subscriptionType;
  final int workingDays;
  final double childPrice;
  final int childPriceRaw;
  final String? error;

  BreakdownModelInfo({
    required this.childId,
    required this.childName,
    required this.schoolName,
    required this.distanceKm,
    required this.pricePerKm,
    required this.subscriptionType,
    required this.workingDays,
    required this.childPrice,
    required this.childPriceRaw,
    this.error,
  });

  factory BreakdownModelInfo.fromJson(Map<String, dynamic> json) {
    return BreakdownModelInfo(
      childId: _readInt(json['child_id']),
      childName: json['child_name']?.toString() ?? '',
      schoolName: json['school_name']?.toString() ?? '',
      distanceKm: _readDouble(json['distance_km']),
      pricePerKm: _readDouble(json['price_per_km']),
      subscriptionType: json['subscription_type']?.toString() ?? 'monthly',
      workingDays: _readInt(json['working_days']),
      childPrice: _readDouble(json['child_price']),
      childPriceRaw: _readInt(json['child_price_raw']),
      error: json['error']?.toString(),
    );
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _readDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

bool _readBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}