import 'package:flutter/foundation.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';

String _resolveMediaUrl(String rawUrl) {
  if (rawUrl.isEmpty) return rawUrl;
  if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
    return rawUrl;
  }
  if (rawUrl.startsWith('//')) return 'https:$rawUrl';

  final serverRoot = ApiEndpoints.baseUrl.replaceAll(RegExp(r'/?api/?$'), '');
  final path = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';
  final resolved = '$serverRoot$path';
  debugPrint('🖼️ [_resolveMediaUrl] rawUrl: $rawUrl -> resolved: $resolved');
  return resolved;
}

class DriverLegalDataModel {
  final String nationalId;
  final String licenseNumber;
  final String licenseExpiry;
  final String? insuranceExpiry;
  final String? stampExpiry;
  final String? technicalInspectionExpiry;
  final String driverStatus;
  final List<DriverUploadedFileModel> uploadedFiles;

  const DriverLegalDataModel({
    required this.nationalId,
    required this.licenseNumber,
    required this.licenseExpiry,
    this.insuranceExpiry,
    this.stampExpiry,
    this.technicalInspectionExpiry,
    required this.driverStatus,
    required this.uploadedFiles,
  });

  factory DriverLegalDataModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📜 [DriverLegalDataModel.fromJson] Incoming json keys: ${json.keys.toList()}');
    final rawFiles = json['uploaded_files'] ?? json['files'] ?? [];
    final List<DriverUploadedFileModel> filesList = [];
    if (rawFiles is List) {
      debugPrint('📜 [DriverLegalDataModel.fromJson] rawFiles length: ${rawFiles.length}');
      for (final item in rawFiles) {
        if (item is Map) {
          final fileModel = DriverUploadedFileModel.fromJson(
            Map<String, dynamic>.from(item),
          );
          filesList.add(fileModel);
          debugPrint('   ➕ Added from uploaded_files: type=${fileModel.type}, url=${fileModel.fileUrl}');
        }
      }
    }

    if (json['documents_map'] is Map) {
      final docMap = Map<String, dynamic>.from(json['documents_map'] as Map);
      debugPrint('📜 [DriverLegalDataModel.fromJson] documents_map keys: ${docMap.keys.toList()}');
      docMap.forEach((docType, url) {
        if (url != null && url.toString().isNotEmpty) {
          final exists = filesList
              .any((f) => f.type.toUpperCase() == docType.toUpperCase());
          if (!exists) {
            final resolvedUrl = _resolveMediaUrl(url.toString());
            filesList.add(
              DriverUploadedFileModel(
                id: 0,
                type: docType,
                fileUrl: resolvedUrl,
                status: json['driver_status']?.toString() ?? 'Pending',
                uploadedAt: '',
              ),
            );
            debugPrint('   ➕ Added from documents_map: docType=$docType, url=$resolvedUrl');
          }
        }
      });
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
      stampExpiry:
          json['stamp_expiry']?.toString() ??
          json['stamp_expiry_date']?.toString(),
      technicalInspectionExpiry:
          json['technical_inspection_expiry']?.toString() ??
          json['technical_inspection_expiry_date']?.toString() ??
          json['inspection_expiry']?.toString(),
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
      if (stampExpiry != null) 'stamp_expiry': stampExpiry,
      if (technicalInspectionExpiry != null)
        'technical_inspection_expiry': technicalInspectionExpiry,
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
  final String? stampExpiryDate;
  final String? technicalInspectionExpiryDate;
  final String? feedback;

  const DriverUploadedFileModel({
    required this.id,
    required this.type,
    required this.fileUrl,
    required this.status,
    required this.uploadedAt,
    this.licenseExpiryDate,
    this.insuranceExpiryDate,
    this.stampExpiryDate,
    this.technicalInspectionExpiryDate,
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
      fileUrl: _resolveMediaUrl(
        json['file_url']?.toString() ??
            json['url']?.toString() ??
            json['path']?.toString() ??
            '',
      ),
      status: json['document_status']?.toString() ??
          json['status']?.toString() ??
          'Pending',
      uploadedAt:
          json['uploaded_at']?.toString() ??
          json['created_at']?.toString() ??
          '',
      licenseExpiryDate: json['license_expiry_date']?.toString(),
      insuranceExpiryDate: json['insurance_expiry_date']?.toString(),
      stampExpiryDate: json['stamp_expiry_date']?.toString(),
      technicalInspectionExpiryDate:
          json['technical_inspection_expiry_date']?.toString(),
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
      if (stampExpiryDate != null) 'stamp_expiry_date': stampExpiryDate,
      if (technicalInspectionExpiryDate != null)
        'technical_inspection_expiry_date': technicalInspectionExpiryDate,
      if (feedback != null) 'feedback': feedback,
    };
  }

  String get typeArabicTitle {
    switch (type.toUpperCase()) {
      case 'LICENSE':
        return 'رخصة القيادة الشخصية';
      case 'INSURANCE':
        return 'وثيقة التأمين الإجباري';
      case 'STAMP':
        return 'الدمغ (ختم التجديد السنوي)';
      case 'TECHNICAL_INSPECTION':
        return 'الفحص الفني للمركبة';
      case 'BOOKLET_PERSONAL_PAGE':
      case 'BOOKLET_PAGE':
        return 'صفحة البيانات الشخصية في الكتيب';
      case 'VEHICLE_LOGBOOK':
        return 'دفتر المركبة (مواصفات الحافلة)';
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
