class DriverLegalDataModel {
  final String nationalId;
  final String licenseNumber;
  final String licenseExpiry;
  final String? insuranceExpiry;
  final String driverStatus;
  final List<DriverUploadedFileModel> uploadedFiles;

  const DriverLegalDataModel({
    required this.nationalId,
    required this.licenseNumber,
    required this.licenseExpiry,
    this.insuranceExpiry,
    required this.driverStatus,
    required this.uploadedFiles,
  });

  factory DriverLegalDataModel.fromJson(Map<String, dynamic> json) {
    final rawFiles = json['uploaded_files'] ?? json['files'] ?? [];
    final List<DriverUploadedFileModel> filesList = [];
    if (rawFiles is List) {
      for (final item in rawFiles) {
        if (item is Map) {
          filesList.add(
            DriverUploadedFileModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    return DriverLegalDataModel(
      nationalId: json['national_id']?.toString() ?? '',
      licenseNumber: json['license_number']?.toString() ?? '',
      licenseExpiry:
          json['license_expiry']?.toString() ??
          json['license_expiry_date']?.toString() ??
          '',
      insuranceExpiry:
          json['insurance_expiry']?.toString() ??
          json['insurance_expiry_date']?.toString(),
      driverStatus:
          json['driver_status']?.toString() ??
          json['account_status']?.toString() ??
          'Pending',
      uploadedFiles: filesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'national_id': nationalId,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry,
      if (insuranceExpiry != null) 'insurance_expiry': insuranceExpiry,
      'driver_status': driverStatus,
      'uploaded_files': uploadedFiles.map((e) => e.toJson()).toList(),
    };
  }
}

class DriverUploadedFileModel {
  final int id;
  final String type;
  final String fileUrl;
  final String status;
  final String uploadedAt;
  final String? licenseExpiryDate;
  final String? insuranceExpiryDate;
  final String? feedback;

  const DriverUploadedFileModel({
    required this.id,
    required this.type,
    required this.fileUrl,
    required this.status,
    required this.uploadedAt,
    this.licenseExpiryDate,
    this.insuranceExpiryDate,
    this.feedback,
  });

  factory DriverUploadedFileModel.fromJson(Map<String, dynamic> json) {
    return DriverUploadedFileModel(
      id: json['id'] is int
          ? json['id']
          : (int.tryParse(json['id']?.toString() ?? '') ?? 0),
      type: json['doc_type']?.toString().toUpperCase() ??
          json['type']?.toString().toUpperCase() ??
          '',
      fileUrl:
          json['file_url']?.toString() ??
          json['url']?.toString() ??
          json['path']?.toString() ??
          '',
      status: json['document_status']?.toString() ??
          json['status']?.toString() ??
          'Pending',
      uploadedAt:
          json['uploaded_at']?.toString() ??
          json['created_at']?.toString() ??
          '',
      licenseExpiryDate: json['license_expiry_date']?.toString(),
      insuranceExpiryDate: json['insurance_expiry_date']?.toString(),
      feedback:
          json['feedback']?.toString() ??
          json['rejection_reason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doc_type': type,
      'file_url': fileUrl,
      'document_status': status,
      'uploaded_at': uploadedAt,
      if (licenseExpiryDate != null) 'license_expiry_date': licenseExpiryDate,
      if (insuranceExpiryDate != null)
        'insurance_expiry_date': insuranceExpiryDate,
      if (feedback != null) 'feedback': feedback,
    };
  }

  String get typeArabicTitle {
    switch (type.toUpperCase()) {
      case 'LICENSE':
        return 'رخصة القيادة';
      case 'VEHICLE_LOGBOOK':
        return 'دفتر المركبة';
      case 'INSURANCE':
        return 'وثيقة التأمين';
      case 'CRIMINAL_RECORD':
        return 'السجل الجنائي';
      default:
        return type.isNotEmpty ? type : 'وثيقة رسمية';
    }
  }

  String get statusArabicText {
    final lower = status.toLowerCase().trim();
    if (lower == 'verified' || lower == 'approved') {
      return 'تم التحقق';
    } else if (lower == 'pending') {
      return 'قيد المراجعة';
    } else if (lower == 'rejected') {
      return 'مرفوض';
    } else if (lower == 'expired') {
      return 'منتهي';
    }
    return status;
  }
}
