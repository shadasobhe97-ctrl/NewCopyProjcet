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
  int get gradeLevel {
    switch (grade) {
      case 'روضة': return 1;
      case 'ابتدائي': return 2;
      case 'إعدادي': return 3;
      case 'ثانوي': return 4;
      default:
        final parsed = int.tryParse(grade);
        if (parsed != null && parsed >= 1 && parsed <= 4) return parsed;
        return 1;
    }
  }

  String get schoolName => school?.name ?? '';
  String get addressName => address?.label ?? '';
  String get qrToken => qrCodeToken ?? '';
  bool get hasActiveSubscription => logistics != null;

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
    return ChildModel(
      id: json['id'] as int?,
      parentId: json['parent_id'] as int?,
      schoolId: json['school_id'] as int? ?? 0,
      addressId: json['address_id']?.toString() ?? '',
      fullName: json['full_name'] as String? ?? json['name'] as String? ?? '',
      gender: json['gender'] as String? ?? 'male',
      birthDate: DateTime.tryParse(json['birth_date'] as String? ?? '') ?? DateTime.now(),
      age: json['age'] as int?,
      grade: (json['grade'] ?? json['grade_level'] ?? 'روضة').toString(),
      photoUrl: json['photo_url'] as String? ?? json['image'] as String?,
      medicalNotes: json['medical_notes'] as String?,
      notificationRadius: (json['notification_radius'] as num?)?.toDouble(),
      qrCodeToken: json['qr_code_token'] as String? ?? json['qr_token'] as String?,
      school: json['school'] != null ? SchoolModel.fromJson(json['school'] as Map<String, dynamic>) : null,
      address: json['address'] != null ? AddressModel.fromJson(json['address'] as Map<String, dynamic>) : null,
      logistics: json['logistics'] != null ? LogisticsModel.fromJson(json['logistics'] as Map<String, dynamic>) : null,
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
      if (school != null) 'school': school,
      if (address != null) 'address': address?.toJson(),
      if (logistics != null) 'logistics': logistics?.toJson(),
    };
  }
}