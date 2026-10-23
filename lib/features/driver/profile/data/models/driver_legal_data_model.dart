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
    final legalDataMap = json['legal_data'] is Map ? json['legal_data'] as Map : json;
    final rawFiles = json['documents'] ?? json['uploaded_files'] ?? json['files'] ?? [];
    final List<DriverUploadedFileModel> filesList = [];
    if (rawFiles is List) {
      debugPrint('📜 [DriverLegalDataModel.fromJson] rawFiles length: ${rawFiles.length}');
      for (final item in rawFiles) {
        if (item is Map) {
          final fileModel = DriverUploadedFileModel.fromJson(
            Map<String, dynamic>.from(item),
          );
          filesList.add(fileModel);
          debugPrint('   ➕ Added from uploaded_files/documents: type=${fileModel.type}, url=${fileModel.fileUrl}');
        }
      }
    }

    if (json['documents_map'] is Map) {
      final docMap = Map<String, dynamic>.from(json['documents_map'] as Map);
      debugPrint('📜 [DriverLegalDataModel.fromJson] documents_map keys: ${docMap.keys.toList()}');
      docMap.forEach((docType, url) {
        if (url != null && url.toString().isNotEmpty) {
          final normDocType = DriverUploadedFileModel.normalizeType(docType);
          final exists = filesList
              .any((f) => DriverUploadedFileModel.normalizeType(f.type) == normDocType);
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
      nationalId: legalDataMap['national_id']?.toString() ?? json['national_id']?.toString() ?? '',
      licenseNumber: legalDataMap['license_number']?.toString() ?? json['license_number']?.toString() ?? '',
      licenseExpiry:
          legalDataMap['license_expiry']?.toString() ??
          json['license_expiry']?.toString() ??
          json['license_expiry_date']?.toString() ??
          '',
      insuranceExpiry:
          legalDataMap['insurance_expiry']?.toString() ??
          json['insurance_expiry']?.toString() ??
          json['insurance_expiry_date']?.toString(),
      stampExpiry:
          legalDataMap['stamp_expiry']?.toString() ??
          json['stamp_expiry']?.toString() ??
          json['stamp_expiry_date']?.toString(),
      technicalInspectionExpiry:
          legalDataMap['technical_inspection_expiry']?.toString() ??
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
      licenseExpiryDate: json['license_expiry_date']?.toString() ?? json['expiry_date']?.toString(),
      insuranceExpiryDate: json['insurance_expiry_date']?.toString() ?? json['expiry_date']?.toString(),
      stampExpiryDate: json['stamp_expiry_date']?.toString() ?? json['expiry_date']?.toString(),
      technicalInspectionExpiryDate:
          json['technical_inspection_expiry_date']?.toString() ?? json['expiry_date']?.toString(),
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

  static String normalizeType(String type) {
    final upper = type.toUpperCase().trim();
    if (upper == 'LICENSE' ||
        upper == 'DOC_LICENSE' ||
        upper == 'LICENSE_DOC' ||
        upper == 'DRIVING_LICENSE' ||
        upper == 'DRIVER_LICENSE') {
      return 'LICENSE';
    }
    if (upper == 'INSURANCE' ||
        upper == 'DOC_INSURANCE' ||
        upper == 'INSURANCE_DOC' ||
        upper == 'VEHICLE_INSURANCE' ||
        upper == 'INSURANCE_POLICY') {
      return 'INSURANCE';
    }
    if (upper == 'STAMP' ||
        upper == 'DOC_STAMP' ||
        upper == 'STAMP_DOC' ||
        upper == 'TAX_STAMP' ||
        upper == 'ANNUAL_STAMP') {
      return 'STAMP';
    }
    if (upper == 'TECHNICAL_INSPECTION' ||
        upper == 'DOC_TECHNICAL_INSPECTION' ||
        upper == 'DOC_INSPECTION' ||
        upper == 'INSPECTION_DOC' ||
        upper == 'INSPECTION' ||
        upper == 'PERIODIC_INSPECTION') {
      return 'TECHNICAL_INSPECTION';
    }
    if (upper == 'VEHICLE_LOGBOOK' ||
        upper == 'DOC_LOGBOOK' ||
        upper == 'LOGBOOK_DOC' ||
        upper == 'DOC_LOGBOOK_VEHICLE' ||
        upper == 'LOGBOOK_VEHICLE_DOC' ||
        upper == 'LOGBOOK' ||
        upper == 'VEHICLE_BOOKLET') {
      return 'VEHICLE_LOGBOOK';
    }
    if (upper == 'BOOKLET_PERSONAL_PAGE' ||
        upper == 'DOC_BOOKLET_PAGE' ||
        upper == 'DOC_LOGBOOK_OWNER' ||
        upper == 'LOGBOOK_OWNER_DOC' ||
        upper == 'BOOKLET_PAGE' ||
        upper == 'BOOKLET') {
      return 'BOOKLET_PERSONAL_PAGE';
    }
    if (upper == 'CRIMINAL_RECORD' ||
        upper == 'DOC_CRIMINAL_RECORD' ||
        upper == 'POLICE_RECORD') {
      return 'CRIMINAL_RECORD';
    }
    if (upper == 'NATIONAL_ID' ||
        upper == 'DOC_NATIONAL_ID' ||
        upper == 'ID_CARD' ||
        upper == 'IDENTITY_CARD') {
      return 'NATIONAL_ID';
    }
    if (upper == 'PERSONAL_PHOTO' ||
        upper == 'AVATAR' ||
        upper == 'PROFILE_IMAGE' ||
        upper == 'PROFILE_PICTURE' ||
        upper == 'PHOTO') {
      return 'PERSONAL_PHOTO';
    }
    if (upper == 'VEHICLE_IMAGE' ||
        upper == 'BUS_IMAGE' ||
        upper == 'VEHICLE_PICTURE') {
      return 'VEHICLE_IMAGE';
    }
    if (upper == 'OPERATION_CARD' ||
        upper == 'OPERATING_CARD' ||
        upper == 'CARD') {
      return 'OPERATION_CARD';
    }
    if (upper == 'HEALTH_CERTIFICATE' ||
        upper == 'MEDICAL_REPORT' ||
        upper == 'MEDICAL_CHECK') {
      return 'HEALTH_CERTIFICATE';
    }
    if (upper == 'PASSPORT' || upper == 'DOC_PASSPORT') {
      return 'PASSPORT';
    }
    if (upper == 'RESIDENCE' || upper == 'RESIDENCY') {
      return 'RESIDENCE';
    }
    return upper;
  }

  String get typeArabicTitle {
    final norm = normalizeType(type);
    switch (norm) {
      case 'LICENSE':
        return 'رخصة القيادة الشخصية';
      case 'INSURANCE':
        return 'وثيقة التأمين الإجباري';
      case 'STAMP':
        return 'الدمغ (ختم التجديد السنوي)';
      case 'TECHNICAL_INSPECTION':
        return 'الفحص الفني للمركبة';
      case 'VEHICLE_LOGBOOK':
        return 'صفحة بيانات المركبة (الكتيب)';
      case 'BOOKLET_PERSONAL_PAGE':
        return 'صفحة البيانات الشخصية (الكتيب)';
      case 'CRIMINAL_RECORD':
        return 'شهادة الحالة الجنائية (السجل الجنائي)';
      case 'NATIONAL_ID':
        return 'بطاقة الهوية الوطنية';
      case 'PERSONAL_PHOTO':
        return 'الصورة الشخصية';
      case 'VEHICLE_IMAGE':
        return 'صورة المركبة / الحافلة';
      case 'OPERATION_CARD':
        return 'بطاقة التشغيل';
      case 'HEALTH_CERTIFICATE':
        return 'الكشف الطبي / الشهادة الصحية';
      case 'PASSPORT':
        return 'جواز السفر';
      case 'RESIDENCE':
        return 'شهادة الإقامة';
      default:
        var cleaned = type.trim();
        if (cleaned.toUpperCase().startsWith('DOC_')) {
          cleaned = cleaned.substring(4);
        }
        if (cleaned.isEmpty) return 'وثيقة رسمية';
        return cleaned.replaceAll('_', ' ');
    }
  }

  String get statusArabicText {
    final lower = status.toLowerCase().trim();
    if (lower == 'verified' || lower == 'approved' || lower == 'active') {
      return 'تم التحقق';
    } else if (lower == 'pending' || lower == 'under_review') {
      return 'قيد المراجعة';
    } else if (lower == 'rejected') {
      return 'مرفوض';
    } else if (lower == 'expired') {
      return 'منتهي الصلاحية';
    } else if (lower == 'missing' || lower == 'required') {
      return 'مطلوب إرفاقه';
    }
    return status;
  }
}

