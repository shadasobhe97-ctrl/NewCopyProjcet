import 'package:flutter/foundation.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'school_model.dart';
import '../../../addresses/data/models/address_model.dart';
import 'logistics_model.dart';
import 'transport_pref_model.dart';

class ChildModel {
  final int? id;
  final int? parentId;
  final int schoolId;
  final String addressId;
  final String fullName;
  final String gender;
  final DateTime birthDate;
  final int? age;
  final String grade; // e.g. "0" to "12" or string
  final String? schoolStage;
  final String? schoolStageLabel;
  final String? photoUrl;
  final String? medicalNotes;
  final double? notificationRadius;
  final String? qrCodeToken;
  final SchoolModel? school;
  final AddressModel? address;
  final LogisticsModel? logistics;

  ChildModel({
    this.id,
    this.parentId,
    required this.schoolId,
    required this.addressId,
    required this.fullName,
    required this.gender,
    required this.birthDate,
    this.age,
    required this.grade,
    this.schoolStage,
    this.schoolStageLabel,
    this.photoUrl,
    this.medicalNotes,
    this.notificationRadius,
    this.qrCodeToken,
    this.school,
    this.address,
    this.logistics,
  });

  // UI Getters for compatibility
  String get name => fullName;
  String? get image => photoUrl;

  int get calculatedAge {
    if (age != null && age! > 0) return age!;
    final now = DateTime.now();
    int yrs = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      yrs--;
    }
    return yrs < 0 ? 0 : yrs;
  }

  bool get hasRealPhoto {
    if (photoUrl == null || photoUrl!.isEmpty) return false;
    final url = photoUrl!.toLowerCase();
    return !url.contains('default-child') &&
           !url.contains('/assets/images/default') &&
           !url.endsWith('default-child.png');
  }
  int get gradeLevel {
    final parsed = int.tryParse(grade);
    if (parsed != null && parsed >= 0 && parsed <= 12) return parsed;
    switch (grade) {
      case 'روضة':
        return 0;
      case 'ابتدائي':
        return 1;
      case 'إعدادي':
        return 7;
      case 'ثانوي':
        return 10;
      default:
        return 0;
    }
  }

  String get schoolName => school?.name ?? '';
  String get addressName => address?.label ?? '';
  String get qrToken => qrCodeToken ?? '';
  bool get hasActiveSubscription => logistics != null;

  String get fullStageAndGradeDisplay {
    final stageText = schoolStageLabel ?? '';
    final gradeText = gradeDisplay;
    if (stageText.isNotEmpty && !gradeText.contains(stageText)) {
      return '$stageText - $gradeText';
    }
    return gradeText;
  }

  String get gradeDisplay {
    final parsed = int.tryParse(grade);
    if (parsed != null) {
      switch (parsed) {
        case 0:
          return 'روضة';
        case 1:
          return 'الصف الأول الابتدائي';
        case 2:
          return 'الصف الثاني الابتدائي';
        case 3:
          return 'الصف الثالث الابتدائي';
        case 4:
          return 'الصف الرابع الابتدائي';
        case 5:
          return 'الصف الخامس الابتدائي';
        case 6:
          return 'الصف السادس الابتدائي';
        case 7:
          return 'الصف السابع (إعدادي)';
        case 8:
          return 'الصف الثامن (إعدادي)';
        case 9:
          return 'الصف التاسع (إعدادي)';
        case 10:
          return 'أول ثانوي (10)';
        case 11:
          return 'ثاني ثانوي (11)';
        case 12:
          return 'ثالث ثانوي (12)';
        default:
          return 'الصف $parsed';
      }
    }
    return grade;
  }

  TransportPrefModel get transportPref {
    if (logistics != null) {
      return TransportPrefModel.fromLogistics(logistics!);
    }
    return TransportPrefModel(
      subscriptionType: 'single_day',
      period: 'morning',
      serviceType: 'both',
      startDate: DateTime.now(),
      schoolStartTime: '08:00 AM',
      schoolEndTime: '01:30 PM',
    );
  }

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    String? resolvedPhotoUrl;
    final rawPhoto =
        json['photo_url']?.toString() ?? json['image']?.toString();
    debugPrint('📸 [ChildModel] raw photo_url: $rawPhoto');
    if (rawPhoto != null && rawPhoto.isNotEmpty) {
      final serverRoot = ApiEndpoints.baseUrl.replaceAll(RegExp(r'/?api/?$'), '');
      if (rawPhoto.startsWith('https://')) {
        resolvedPhotoUrl = rawPhoto;
      } else if (rawPhoto.startsWith('http://')) {
        resolvedPhotoUrl = 'https://${rawPhoto.substring(7)}';
      } else if (rawPhoto.startsWith('//')) {
        resolvedPhotoUrl = 'https:$rawPhoto';
      } else {
        final path = rawPhoto.startsWith('/') ? rawPhoto : '/$rawPhoto';
        resolvedPhotoUrl = '$serverRoot$path';
      }
    }
    debugPrint('📸 [ChildModel] resolved photoUrl: $resolvedPhotoUrl');

    final rawParentId = json['parent_id'];
    final parsedParentId = rawParentId is int
        ? rawParentId
        : int.tryParse(rawParentId?.toString() ?? '');

    final rawSchoolId = json['school_id'];
    final parsedSchoolId = rawSchoolId is int
        ? rawSchoolId
        : int.tryParse(rawSchoolId?.toString() ?? '') ?? 0;

    return ChildModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      parentId: parsedParentId,
      schoolId: parsedSchoolId,
      addressId: json['address_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? json['name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? 'male',
      birthDate:
          DateTime.tryParse(json['birth_date']?.toString() ?? '') ??
          DateTime.now(),
      age: json['age'] is int ? json['age'] as int : int.tryParse(json['age']?.toString() ?? ''),
      grade: (json['grade'] ?? json['grade_level'] ?? 'روضة').toString(),
      schoolStage: json['school_stage']?.toString(),
      schoolStageLabel: json['school_stage_label']?.toString(),
      photoUrl: resolvedPhotoUrl,
      medicalNotes: json['medical_notes']?.toString(),
      notificationRadius: (json['notification_radius'] as num?)?.toDouble(),
      qrCodeToken:
          json['qr_code_token']?.toString() ?? json['qr_token']?.toString(),
      school: json['school'] is Map
          ? SchoolModel.fromJson(Map<String, dynamic>.from(json['school'] as Map))
          : null,
      address: json['address'] is Map
          ? AddressModel.fromJson(Map<String, dynamic>.from(json['address'] as Map))
          : null,
      logistics: json['logistics'] is Map
          ? LogisticsModel.fromJson(Map<String, dynamic>.from(json['logistics'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (parentId != null) 'parent_id': parentId,
      'school_id': schoolId,
      'address_id': addressId,
      'full_name': fullName,
      'gender': gender,
      'birth_date': birthDate.toIso8601String().split('T').first,
      'grade': grade,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (medicalNotes != null) 'medical_notes': medicalNotes,
      if (notificationRadius != null) 'notification_radius': notificationRadius,
      if (qrCodeToken != null) 'qr_code_token': qrCodeToken,
      if (school != null) 'school': school!.toJson(),
      if (address != null) 'address': address?.toJson(),
      if (logistics != null) 'logistics': logistics?.toJson(),
    };
  }
}
