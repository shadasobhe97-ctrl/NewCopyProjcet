import 'package:kids_transport/core/utils/app_image_helper.dart';
import 'school_model.dart';
import '../../../addresses/data/models/address_model.dart';
import 'logistics_model.dart';
import 'transport_pref_model.dart';

class ChildModel {
  final int? id;
  final int? userId;
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
  final String? pickupTime;
  final String? dropoffTime;

  ChildModel({
    this.id,
    this.userId,
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
    this.pickupTime,
    this.dropoffTime,
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

  bool get hasRealPhoto => AppImageHelper.isValidImageUrl(photoUrl);
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
  String? get effectivePickupTime => pickupTime ?? logistics?.pickupTime;
  String? get effectiveDropoffTime => dropoffTime ?? logistics?.dropoffTime;

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

  ChildModel copyWith({
    int? id,
    int? userId,
    int? schoolId,
    String? addressId,
    String? fullName,
    String? gender,
    DateTime? birthDate,
    int? age,
    String? grade,
    String? schoolStage,
    String? schoolStageLabel,
    String? photoUrl,
    String? medicalNotes,
    double? notificationRadius,
    String? qrCodeToken,
    SchoolModel? school,
    AddressModel? address,
    LogisticsModel? logistics,
    String? pickupTime,
    String? dropoffTime,
  }) {
    return ChildModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      schoolId: schoolId ?? this.schoolId,
      addressId: addressId ?? this.addressId,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      age: age ?? this.age,
      grade: grade ?? this.grade,
      schoolStage: schoolStage ?? this.schoolStage,
      schoolStageLabel: schoolStageLabel ?? this.schoolStageLabel,
      photoUrl: photoUrl ?? this.photoUrl,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      notificationRadius: notificationRadius ?? this.notificationRadius,
      qrCodeToken: qrCodeToken ?? this.qrCodeToken,
      school: school ?? this.school,
      address: address ?? this.address,
      logistics: logistics ?? this.logistics,
      pickupTime: pickupTime ?? this.pickupTime,
      dropoffTime: dropoffTime ?? this.dropoffTime,
    );
  }

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    final rawPhoto =
        json['photo_url']?.toString() ?? json['image']?.toString();
    final resolvedPhotoUrl = AppImageHelper.resolveUrl(rawPhoto);

    final rawUserId = json['user_id'];
    final parsedUserId = rawUserId is int
        ? rawUserId
        : int.tryParse(rawUserId?.toString() ?? '');

    final rawSchoolId = json['school_id'];
    final parsedSchoolId = rawSchoolId is int
        ? rawSchoolId
        : int.tryParse(rawSchoolId?.toString() ?? '') ?? 0;

    final rawLogistics = json['logistics'] is Map
        ? LogisticsModel.fromJson(Map<String, dynamic>.from(json['logistics'] as Map))
        : (json['subscription'] is Map
            ? LogisticsModel.fromJson(Map<String, dynamic>.from(json['subscription'] as Map))
            : null);

    final resolvedPickupTime = json['pickup_time']?.toString() ??
        json['school_start_time']?.toString() ??
        rawLogistics?.pickupTime;

    final resolvedDropoffTime = json['dropoff_time']?.toString() ??
        json['school_end_time']?.toString() ??
        rawLogistics?.dropoffTime;

    final effectiveLogistics = rawLogistics ??
        ((resolvedPickupTime != null || resolvedDropoffTime != null)
            ? LogisticsModel(
                preferredTimeSlot: json['preferred_time_slot']?.toString() ?? 'morning',
                tripDirection: json['trip_direction']?.toString() ?? 'both',
                pickupTime: resolvedPickupTime,
                dropoffTime: resolvedDropoffTime,
                startDate: DateTime.tryParse(json['start_date']?.toString() ?? '') ?? DateTime.now(),
                subscriptionType: json['subscription_type']?.toString() ?? 'monthly',
              )
            : null);

    return ChildModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      userId: parsedUserId,
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
      logistics: effectiveLogistics,
      pickupTime: resolvedPickupTime,
      dropoffTime: resolvedDropoffTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
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
      if (pickupTime != null) 'pickup_time': pickupTime,
      if (dropoffTime != null) 'dropoff_time': dropoffTime,
    };
  }
}
