class VehicleModel {
  final int id;
  final String brand;
  final String model;
  final int year;
  final String plateNumber;
  final int capacityManual;
  final String? vehicleImage;
  final String? nationalId;
  final String? licenseNumber;
  final String? licenseExpiry;

  VehicleModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.plateNumber,
    required this.capacityManual,
    this.vehicleImage,
    this.nationalId,
    this.licenseNumber,
    this.licenseExpiry,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? 0,
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] is String
          ? int.parse(json['year'])
          : (json['year'] ?? 2000),
      plateNumber: json['plate_number'] ?? '',
      capacityManual: json['capacity_manual'] is String
          ? int.parse(json['capacity_manual'])
          : (json['capacity_manual'] ?? 0),
      vehicleImage: json['vehicle_image'],
      nationalId: json['national_id'],
      licenseNumber: json['license_number'],
      licenseExpiry: json['license_expiry'],
    );
  }
}
