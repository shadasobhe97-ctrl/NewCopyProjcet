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
  final String grade; // e.g. "روضة", "ابتدائي", "إعدادي", "ثانوي" or numeric
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
  bool get hasRealPhoto {
    if (photoUrl == null || photoUrl!.isEmpty) return false;
    final url = photoUrl!.toLowerCase();
    return !url.contains('default-child') &&
           !url.contains('/assets/images/default') &&
           !url.endsWith('default-child.png');
  }
  int get gradeLevel {
    switch (grade) {
      case 'روضة':
        return 1;
      case 'ابتدائي':
        return 2;
      case 'إعدادي':
        return 3;
      case 'ثانوي':
        return 4;
      default:
        final parsed = int.tryParse(grade);
        if (parsed != null && parsed >= 1) return parsed;
        return 1;
    }
  }

  String get schoolName => school?.name ?? '';
  String get addressName => address?.label ?? '';
  String get qrToken => qrCodeToken ?? '';
  bool get hasActiveSubscription => logistics != null;

  String get gradeDisplay {
    final parsed = int.tryParse(grade);
    if (parsed != null) {
      switch (parsed) {
        case 1:
          return 'الصف الأول';
        case 2:
          return 'الصف الثاني';
        case 3:
          return 'الصف الثالث';
        case 4:
          return 'الصف الرابع';
        case 5:
          return 'الصف الخامس';
        case 6:
          return 'الصف السادس';
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
      subscriptionType: 'monthly',
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
