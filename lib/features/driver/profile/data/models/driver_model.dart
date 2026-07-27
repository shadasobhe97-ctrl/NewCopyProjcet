class DriverModel {
  final int driverId;
  final int userId;
  final int roleId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? alternativePhone;
  final String? newEmailTemporary;
  final bool emailChangePending;
  final String? avatarUrl;
  final String gender;
  final bool isActive;
  final String nationalId;
  final String licenseNumber;
  final String driverStatus;

  // Legacy meta_sync fields for backward compatibility
  final bool hasPendingChanges;
  final String? pendingFullName;
  final String? pendingPhoneNumber;
  final String? pendingEmail;

  const DriverModel({
    required this.driverId,
    required this.userId,
    this.roleId = 4,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.alternativePhone,
    this.newEmailTemporary,
    this.emailChangePending = false,
    this.avatarUrl,
    required this.gender,
    this.isActive = true,
    this.nationalId = '',
    this.licenseNumber = '',
    String? driverStatus,
    String? accountStatus,
    this.hasPendingChanges = false,
    this.pendingFullName,
    this.pendingPhoneNumber,
    this.pendingEmail,
  }) : driverStatus = driverStatus ?? accountStatus ?? 'Approved';

  String get accountStatus => driverStatus;

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    final metaSync = json['meta_sync'] is Map ? Map<String, dynamic>.from(json['meta_sync'] as Map) : null;
    final pendingData = metaSync?['pending_data'] is Map ? Map<String, dynamic>.from(metaSync!['pending_data'] as Map) : null;

    return DriverModel(
      driverId: json['driver_id'] is int ? json['driver_id'] : (int.tryParse(json['driver_id']?.toString() ?? '') ?? 0),
      userId: json['user_id'] is int ? json['user_id'] : (int.tryParse(json['user_id']?.toString() ?? '') ?? 0),
      roleId: json['role_id'] is int ? json['role_id'] : (int.tryParse(json['role_id']?.toString() ?? '') ?? 4),
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      alternativePhone: json['alternative_phone']?.toString(),
      newEmailTemporary: json['new_email_temporary']?.toString(),
      emailChangePending: json['email_change_pending'] ?? false,
      avatarUrl: json['avatar_url']?.toString(),
      gender: json['gender']?.toString() ?? '',
      isActive: json['is_active'] ?? true,
      nationalId: json['national_id']?.toString() ?? '',
      licenseNumber: json['license_number']?.toString() ?? '',
      driverStatus: json['driver_status']?.toString() ?? json['account_status']?.toString() ?? 'Approved',
      hasPendingChanges: metaSync?['has_pending_changes'] ?? false,
      pendingFullName: pendingData?['full_name']?.toString(),
      pendingPhoneNumber: pendingData?['phone_number']?.toString(),
      pendingEmail: pendingData?['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driver_id': driverId,
      'user_id': userId,
      'role_id': roleId,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'alternative_phone': alternativePhone,
      'new_email_temporary': newEmailTemporary,
      'email_change_pending': emailChangePending,
      'avatar_url': avatarUrl,
      'gender': gender,
      'is_active': isActive,
      'national_id': nationalId,
      'license_number': licenseNumber,
      'driver_status': driverStatus,
      'account_status': accountStatus,
      'has_pending_changes': hasPendingChanges,
      'pending_full_name': pendingFullName,
      'pending_phone_number': pendingPhoneNumber,
      'pending_email': pendingEmail,
    };
  }
}

