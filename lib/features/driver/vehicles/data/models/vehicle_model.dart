class VehicleModel {
  final int id;
  final String brand;
  final String model;
  final int year;
  final String plateNumber;
  final String? color;
  final String? type;
  final int capacityManual;
  final int? capacityAi;
  final bool? isVerified;
  final bool? hasAc;
  final String? vehicleImageUrl;
  final String? status;
  final String? nationalId;
  final String? licenseNumber;
  final String? licenseExpiry;

  VehicleModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.plateNumber,
    this.color,
    this.type,
    required this.capacityManual,
    this.capacityAi,
    this.isVerified,
    this.hasAc,
    this.vehicleImageUrl,
    this.status,
    this.nationalId,
    this.licenseNumber,
    this.licenseExpiry,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    int parsedYear = 2022;
    if (json['year'] is int) {
      parsedYear = json['year'];
    } else if (json['year'] != null) {
      parsedYear = int.tryParse(json['year'].toString()) ?? 2022;
    }

    int parsedCap = 0;
    if (json['capacity_manual'] is int) {
      parsedCap = json['capacity_manual'];
    } else if (json['capacity'] is int) {
      parsedCap = json['capacity'];
    } else if (json['capacity_manual'] != null) {
      parsedCap = int.tryParse(json['capacity_manual'].toString()) ?? 0;
    }

    bool? parsedAc;
    if (json['has_ac'] is bool) {
      parsedAc = json['has_ac'];
    } else if (json['has_ac'] != null) {
      final str = json['has_ac'].toString().toLowerCase().trim();
      parsedAc = str == '1' || str == 'true';
    }

    return VehicleModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      brand: json['brand']?.toString() ?? json['make']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      year: parsedYear,
      plateNumber: json['plate_number']?.toString() ?? '',
      color: json['color']?.toString(),
      type: json['type']?.toString(),
      capacityManual: parsedCap,
      capacityAi: (json['capacity_ai'] as num?)?.toInt(),
      isVerified: json['is_verified'] as bool?,
      hasAc: parsedAc,
      vehicleImageUrl: json['vehicle_image_url']?.toString() ??
          json['vehicle_image_path']?.toString() ??
          json['vehicle_image']?.toString(),
      status: json['status']?.toString(),
      nationalId: json['national_id']?.toString(),
      licenseNumber: json['license_number']?.toString(),
      licenseExpiry: json['license_expiry']?.toString(),
    );
  }
}
