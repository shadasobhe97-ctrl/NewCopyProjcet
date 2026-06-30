class DriverCompleteProfileRequest {
  final String nationalId;
  final String licenseNumber;
  final String licenseExpiry; // صيغة YYYY-MM-DD
  final String plateNumber;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String type; // Bus, Van, Sedan
  final int capacityManual;
  final int hasAc; // 1 للمتوفر، 0 للغير متوفر
  final String vehicleImagePath;
  final String docLicensePath;
  final String docLogbookPath;
  final String docInsurancePath;
  final String docCriminalRecordPath;
  final String? alternativePhone; // الهاتف البديل المضاف من قبلكِ

  DriverCompleteProfileRequest({
    required this.nationalId,
    required this.licenseNumber,
    required this.licenseExpiry,
    required this.plateNumber,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.type,
    required this.capacityManual,
    required this.hasAc,
    required this.vehicleImagePath,
    required this.docLicensePath,
    required this.docLogbookPath,
    required this.docInsurancePath,
    required this.docCriminalRecordPath,
    this.alternativePhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'national_id': nationalId,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry,
      'plate_number': plateNumber,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'type': type,
      'capacity_manual': capacityManual,
      'has_ac': hasAc,
      'vehicle_image_path': vehicleImagePath,
      'doc_license_path': docLicensePath,
      'doc_logbook_path': docLogbookPath,
      'doc_insurance_path': docInsurancePath,
      'doc_criminal_record_path': docCriminalRecordPath,
      'alternative_phone': alternativePhone,
    };
  }
}