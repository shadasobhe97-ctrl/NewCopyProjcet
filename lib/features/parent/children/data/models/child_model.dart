enum PreferredTimeSlot { MORNING, EVENING, BOTH }
enum DailyStatus { present, absent }

class ChildModel {
  final String? id;
  final String? parentId;
  final String schoolId;
  final String schoolName; // مضاف للـ UX لعرضه مباشرة
  final String fullName;
  final DateTime birthDate;
  final String homeAddressId;
  final String homeAddressTitle; // مضاف للـ UX
  final int notificationRadius;
  final String? qrCodeToken;
  final DailyStatus dailyStatus;
  final String? photoUrl;
  final String? medicalNotes;
  final PreferredTimeSlot preferredTimeSlot;
  final String? notes;
  final String gender; // نوع الطفل
  // وقت الذهاب والرجوع (اختياري)
  final String? departureTime;
  final String? returnTime;

  ChildModel({
    this.id,
    this.parentId,
    required this.schoolId,
    required this.schoolName,
    required this.fullName,
    required this.birthDate,
    required this.homeAddressId,
    required this.homeAddressTitle,
    this.notificationRadius = 200,
    this.qrCodeToken,
    this.dailyStatus = DailyStatus.present,
    this.photoUrl,
    this.medicalNotes,
    required this.preferredTimeSlot,
    this.notes,
    required this.gender,
    this.departureTime,
    this.returnTime,
  });

  /// copyWith لتسهيل التحديث الجزئي
  ChildModel copyWith({
    String? id,
    String? parentId,
    String? schoolId,
    String? schoolName,
    String? fullName,
    DateTime? birthDate,
    String? homeAddressId,
    String? homeAddressTitle,
    int? notificationRadius,
    String? qrCodeToken,
    DailyStatus? dailyStatus,
    String? photoUrl,
    String? medicalNotes,
    PreferredTimeSlot? preferredTimeSlot,
    String? notes,
    String? gender,
    String? departureTime,
    String? returnTime,
  }) {
    return ChildModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
      fullName: fullName ?? this.fullName,
      birthDate: birthDate ?? this.birthDate,
      homeAddressId: homeAddressId ?? this.homeAddressId,
      homeAddressTitle: homeAddressTitle ?? this.homeAddressTitle,
      notificationRadius: notificationRadius ?? this.notificationRadius,
      qrCodeToken: qrCodeToken ?? this.qrCodeToken,
      dailyStatus: dailyStatus ?? this.dailyStatus,
      photoUrl: photoUrl ?? this.photoUrl,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      preferredTimeSlot: preferredTimeSlot ?? this.preferredTimeSlot,
      notes: notes ?? this.notes,
      gender: gender ?? this.gender,
      departureTime: departureTime ?? this.departureTime,
      returnTime: returnTime ?? this.returnTime,
    );
  }

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'],
      parentId: json['parent_id'],
      schoolId: json['school_id'] ?? '',
      schoolName: json['school_name'] ?? '',
      fullName: json['full_name'] ?? '',
      birthDate: DateTime.parse(json['birth_date'] ?? DateTime.now().toString()),
      homeAddressId: json['home_address_id'] ?? '',
      homeAddressTitle: json['home_address_title'] ?? '',
      notificationRadius: json['notification_radius'] ?? 200,
      qrCodeToken: json['qr_code_token'],
      dailyStatus: json['daily_status'] == 'absent' ? DailyStatus.absent : DailyStatus.present,
      photoUrl: json['photo_url'],
      medicalNotes: json['medical_notes'],
      preferredTimeSlot: _parseTimeSlot(json['preferred_time_slot']),
      notes: json['notes'],
      gender: json['gender'] ?? '',
      departureTime: json['departure_time'],
      returnTime: json['return_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'school_id': schoolId,
      'school_name': schoolName,
      'full_name': fullName,
      'birth_date': birthDate.toIso8601String().split('T').first,
      'home_address_id': homeAddressId,
      'home_address_title': homeAddressTitle,
      'notification_radius': notificationRadius,
      'qr_code_token': qrCodeToken,
      'daily_status': dailyStatus.name,
      'photo_url': photoUrl,
      'medical_notes': medicalNotes,
      'preferred_time_slot': preferredTimeSlot.name,
      'notes': notes,
      'gender': gender,
      'departure_time': departureTime,
      'return_time': returnTime,
    };
  }

  static PreferredTimeSlot _parseTimeSlot(String? slot) {
    if (slot == 'EVENING') return PreferredTimeSlot.EVENING;
    if (slot == 'BOTH') return PreferredTimeSlot.BOTH;
    return PreferredTimeSlot.MORNING;
  }
}