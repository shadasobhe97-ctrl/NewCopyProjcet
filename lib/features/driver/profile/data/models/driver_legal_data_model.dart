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
  final String? expiryDate;
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
    this.expiryDate,
    this.licenseExpiryDate,
    this.insuranceExpiryDate,
    this.stampExpiryDate,
    this.technicalInspectionExpiryDate,
    this.feedback,
  });

  factory DriverUploadedFileModel.fromJson(Map<String, dynamic> json) {
    final directExpiry = json['expiry_date']?.toString() ??
        json['expiry']?.toString() ??
        json['expires_at']?.toString();

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
      expiryDate: directExpiry,
      licenseExpiryDate: json['license_expiry_date']?.toString() ?? directExpiry,
      insuranceExpiryDate: json['insurance_expiry_date']?.toString() ?? directExpiry,
      stampExpiryDate: json['stamp_expiry_date']?.toString() ?? directExpiry,
      technicalInspectionExpiryDate:
          json['technical_inspection_expiry_date']?.toString() ?? directExpiry,
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
      if (expiryDate != null) 'expiry_date': expiryDate,
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
        upper == 'DRIVER_LICENSE' ||
        upper == 'LICENSE_PHOTO' ||
        upper == 'LICENSE_IMAGE' ||
        upper == 'LICENSE_CARD' ||
        upper == 'DOC_DRIVING_LICENSE' ||
        upper == 'DRIVER_LICENSE_FRONT') {
      return 'LICENSE';
    }
    if (upper == 'INSURANCE' ||
        upper == 'DOC_INSURANCE' ||
        upper == 'INSURANCE_DOC' ||
        upper == 'VEHICLE_INSURANCE' ||
        upper == 'INSURANCE_POLICY' ||
        upper == 'CAR_INSURANCE' ||
        upper == 'INSURANCE_CARD' ||
        upper == 'THIRD_PARTY_INSURANCE' ||
        upper == 'COMPREHENSIVE_INSURANCE') {
      return 'INSURANCE';
    }
    if (upper == 'STAMP' ||
        upper == 'DOC_STAMP' ||
        upper == 'STAMP_DOC' ||
        upper == 'TAX_STAMP' ||
        upper == 'ANNUAL_STAMP' ||
        upper == 'RENEWAL_STAMP' ||
        upper == 'STAMP_IMAGE') {
      return 'STAMP';
    }
    if (upper == 'TECHNICAL_INSPECTION' ||
        upper == 'DOC_TECHNICAL_INSPECTION' ||
        upper == 'DOC_INSPECTION' ||
        upper == 'INSPECTION_DOC' ||
        upper == 'INSPECTION' ||
        upper == 'PERIODIC_INSPECTION' ||
        upper == 'MVPI' ||
        upper == 'VEHICLE_INSPECTION' ||
        upper == 'CAR_INSPECTION') {
      return 'TECHNICAL_INSPECTION';
    }
    if (upper == 'VEHICLE_LOGBOOK' ||
        upper == 'DOC_LOGBOOK' ||
        upper == 'LOGBOOK_DOC' ||
        upper == 'DOC_LOGBOOK_VEHICLE' ||
        upper == 'LOGBOOK_VEHICLE_DOC' ||
        upper == 'LOGBOOK' ||
        upper == 'VEHICLE_BOOKLET' ||
        upper == 'CAR_LOGBOOK' ||
        upper == 'CAR_REGISTRATION' ||
        upper == 'VEHICLE_REGISTRATION') {
      return 'VEHICLE_LOGBOOK';
    }
    if (upper == 'BOOKLET_PERSONAL_PAGE' ||
        upper == 'DOC_BOOKLET_PAGE' ||
        upper == 'DOC_LOGBOOK_OWNER' ||
        upper == 'LOGBOOK_OWNER_DOC' ||
        upper == 'BOOKLET_PAGE' ||
        upper == 'BOOKLET' ||
        upper == 'OWNER_LOGBOOK' ||
        upper == 'LOGBOOK_OWNER') {
      return 'BOOKLET_PERSONAL_PAGE';
    }
    if (upper == 'CRIMINAL_RECORD' ||
        upper == 'DOC_CRIMINAL_RECORD' ||
        upper == 'POLICE_RECORD' ||
        upper == 'POLICE_CLEARANCE' ||
        upper == 'NON_CONVICTION' ||
        upper == 'CRIMINAL_STATUS') {
      return 'CRIMINAL_RECORD';
    }
    if (upper == 'NATIONAL_ID' ||
        upper == 'DOC_NATIONAL_ID' ||
        upper == 'ID_CARD' ||
        upper == 'IDENTITY_CARD' ||
        upper == 'NATIONAL_IDENTITY' ||
        upper == 'ID_FRONT' ||
        upper == 'ID_BACK' ||
        upper == 'NATIONAL_ID_FRONT' ||
        upper == 'NATIONAL_ID_BACK') {
      return 'NATIONAL_ID';
    }
    if (upper == 'PERSONAL_PHOTO' ||
        upper == 'AVATAR' ||
        upper == 'PROFILE_IMAGE' ||
        upper == 'PROFILE_PICTURE' ||
        upper == 'PHOTO' ||
        upper == 'DRIVER_PHOTO' ||
        upper == 'DRIVER_IMAGE' ||
        upper == 'USER_IMAGE') {
      return 'PERSONAL_PHOTO';
    }
    if (upper == 'VEHICLE_IMAGE' ||
        upper == 'BUS_IMAGE' ||
        upper == 'VEHICLE_PICTURE' ||
        upper == 'CAR_IMAGE' ||
        upper == 'CAR_PHOTO' ||
        upper == 'VEHICLE_PHOTO') {
      return 'VEHICLE_IMAGE';
    }
    if (upper == 'VEHICLE_FRONT' || upper == 'CAR_FRONT') {
      return 'VEHICLE_FRONT';
    }
    if (upper == 'VEHICLE_BACK' || upper == 'CAR_BACK' || upper == 'CAR_REAR') {
      return 'VEHICLE_BACK';
    }
    if (upper == 'VEHICLE_SIDE' || upper == 'CAR_SIDE') {
      return 'VEHICLE_SIDE';
    }
    if (upper == 'VEHICLE_INTERIOR' || upper == 'CAR_INSIDE' || upper == 'INTERIOR') {
      return 'VEHICLE_INTERIOR';
    }
    if (upper == 'OPERATION_CARD' ||
        upper == 'OPERATING_CARD' ||
        upper == 'CARD' ||
        upper == 'TRANSPORT_CARD' ||
        upper == 'OPERATIONAL_CARD') {
      return 'OPERATION_CARD';
    }
    if (upper == 'HEALTH_CERTIFICATE' ||
        upper == 'MEDICAL_REPORT' ||
        upper == 'MEDICAL_CHECK' ||
        upper == 'HEALTH_REPORT' ||
        upper == 'MEDICAL_FITNESS' ||
        upper == 'DRUG_TEST') {
      return 'HEALTH_CERTIFICATE';
    }
    if (upper == 'PASSPORT' || upper == 'DOC_PASSPORT' || upper == 'PASSPORT_IMAGE') {
      return 'PASSPORT';
    }
    if (upper == 'RESIDENCE' ||
        upper == 'RESIDENCY' ||
        upper == 'RESIDENCE_PERMIT' ||
        upper == 'IQAMA') {
      return 'RESIDENCE';
    }
    if (upper == 'DELEGATION' ||
        upper == 'DELEGATION_LETTER' ||
        upper == 'AUTHORIZATION' ||
        upper == 'AUTHORIZATION_LETTER' ||
        upper == 'POWER_OF_ATTORNEY') {
      return 'DELEGATION';
    }
    if (upper == 'TAX_CARD' ||
        upper == 'TAX_CERTIFICATE' ||
        upper == 'TAX_RECORD') {
      return 'TAX_CARD';
    }
    if (upper == 'COMMERCIAL_REGISTER' ||
        upper == 'COMMERCIAL_REGISTRATION' ||
        upper == 'CR') {
      return 'COMMERCIAL_REGISTER';
    }
    if (upper == 'CONTRACT' ||
        upper == 'EMPLOYMENT_CONTRACT' ||
        upper == 'AGREEMENT' ||
        upper == 'DRIVER_CONTRACT') {
      return 'CONTRACT';
    }
    if (upper == 'IBAN' ||
        upper == 'BANK_CERTIFICATE' ||
        upper == 'BANK_ACCOUNT' ||
        upper == 'BANK_CARD' ||
        upper == 'BANK_STATEMENT') {
      return 'IBAN';
    }
    if (upper == 'PLATE_NUMBER' ||
        upper == 'PLATE_NUMBER_IMAGE' ||
        upper == 'CAR_PLATE' ||
        upper == 'LICENSE_PLATE') {
      return 'PLATE_NUMBER';
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
        return 'كتيب المركبة (صفحة بيانات المركبة)';
      case 'BOOKLET_PERSONAL_PAGE':
        return 'كتيب المركبة (صفحة المالك والبيانات الشخصية)';
      case 'CRIMINAL_RECORD':
        return 'شهادة الحالة الجنائية (السجل الجنائي)';
      case 'NATIONAL_ID':
        return 'بطاقة الهوية الوطنية';
      case 'PERSONAL_PHOTO':
        return 'الصورة الشخصية للسائق';
      case 'VEHICLE_IMAGE':
        return 'صورة المركبة / الحافلة';
      case 'VEHICLE_FRONT':
        return 'صورة المركبة من الأمام';
      case 'VEHICLE_BACK':
        return 'صورة المركبة من الخلف';
      case 'VEHICLE_SIDE':
        return 'صورة المركبة من الجانب';
      case 'VEHICLE_INTERIOR':
        return 'صورة المركبة من الداخل (المقاعد)';
      case 'OPERATION_CARD':
        return 'بطاقة تشغيل المركبة';
      case 'HEALTH_CERTIFICATE':
        return 'الكشف الطبي / الشهادة الصحية';
      case 'PASSPORT':
        return 'جواز السفر';
      case 'RESIDENCE':
        return 'شهادة الإقامة / تصريح الإقامة';
      case 'DELEGATION':
        return 'تفويض / توكيل قيادة المركبة';
      case 'TAX_CARD':
        return 'البطاقة الضريبية';
      case 'COMMERCIAL_REGISTER':
        return 'السجل التجاري';
      case 'CONTRACT':
        return 'عقد العمل والتشغيل';
      case 'IBAN':
        return 'إفادة الحساب المصرفي (IBAN)';
      case 'PLATE_NUMBER':
        return 'صورة لوحة المركبة';
      default:
        return _translateDocTypeFallback(type);
    }
  }

  static String _translateDocTypeFallback(String rawType) {
    var cleaned = rawType.trim().toLowerCase();
    if (cleaned.startsWith('doc_')) {
      cleaned = cleaned.substring(4);
    }
    if (cleaned.isEmpty) return 'وثيقة رسمية';

    final Map<String, String> wordMap = {
      'license': 'رخصة',
      'driving': 'قيادة',
      'driver': 'سائق',
      'insurance': 'تأمين',
      'inspection': 'فحص',
      'technical': 'فني',
      'stamp': 'دمغة',
      'logbook': 'كتيب',
      'booklet': 'كتيب',
      'vehicle': 'مركبة',
      'car': 'سيارة',
      'bus': 'حافلة',
      'card': 'بطاقة',
      'id': 'هوية',
      'national': 'وطنية',
      'photo': 'صورة',
      'image': 'صورة',
      'picture': 'صورة',
      'front': 'أمامي',
      'back': 'خلفي',
      'rear': 'خلفي',
      'side': 'جانبي',
      'interior': 'داخلي',
      'inside': 'داخلي',
      'owner': 'مالك',
      'page': 'صفحة',
      'record': 'سجل',
      'criminal': 'جنائي',
      'police': 'شرطة',
      'health': 'صحة',
      'medical': 'طبي',
      'certificate': 'شهادة',
      'passport': 'جواز سفر',
      'residence': 'إقامة',
      'residency': 'إقامة',
      'delegation': 'تفويض',
      'authorization': 'تفويض',
      'contract': 'عقد',
      'tax': 'ضريبة',
      'commercial': 'تجاري',
      'bank': 'مصرفي',
      'account': 'حساب',
      'plate': 'لوحة',
      'number': 'رقم',
    };

    final tokens = cleaned.split(RegExp(r'[_\-\s]+'));
    final translatedTokens = tokens.map((token) {
      return wordMap[token] ?? token;
    }).toList();

    // إذا كانت جميع الكلمات قد تُرجمت للعربية
    final allArabic = translatedTokens.every(
      (t) => RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(t),
    );

    if (allArabic) {
      return translatedTokens.join(' ');
    }

    return 'وثيقة رسمية (${rawType.replaceAll('_', ' ')})';
  }

  static String translateStatusToArabic(String rawStatus) {
    final lower = rawStatus.toLowerCase().trim();
    if (lower == 'verified' || lower == 'approved' || lower == 'active' || lower == 'valid') {
      return 'تم التحقق والاعتماد';
    } else if (lower == 'pending' ||
        lower == 'under_review' ||
        lower == 'in_review' ||
        lower == 'submitted') {
      return 'قيد المراجعة والتدقيق';
    } else if (lower == 'rejected' || lower == 'declined') {
      return 'مرفوضة';
    } else if (lower == 'expired') {
      return 'منتهية الصلاحية';
    } else if (lower == 'expiring_soon' || lower == 'warning') {
      return 'شارفت على الانتهاء';
    } else if (lower == 'missing' || lower == 'required' || lower == 'not_uploaded') {
      return 'مطلوب إرفاقها';
    } else if (lower == 'suspended') {
      return 'موقوفة مؤقتاً';
    } else if (lower == 'inactive') {
      return 'غير نشطة';
    } else if (lower == 'draft') {
      return 'مسودة';
    } else if (lower == 'action_required' || lower == 'needs_update') {
      return 'تتطلب التحديث';
    }
    return rawStatus;
  }

  String get statusArabicText {
    return translateStatusToArabic(status);
  }
}

