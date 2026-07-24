class DriverModel {
  final int driverId;
  final int userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? alternativePhone;
  final String? avatarUrl;
  final String gender;
  final String accountStatus;
  final bool hasPendingChanges;
  final String? pendingFullName;
  final String? pendingPhoneNumber;
  final String? pendingEmail;

  const DriverModel({
    required this.driverId,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.alternativePhone,
    this.avatarUrl,
    required this.gender,
    required this.accountStatus,
    this.hasPendingChanges = false,
    this.pendingFullName,
    this.pendingPhoneNumber,
    this.pendingEmail,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    final metaSync = json['meta_sync'] is Map ? Map<String, dynamic>.from(json['meta_sync'] as Map) : null;
    final pendingData = metaSync?['pending_data'] is Map ? Map<String, dynamic>.from(metaSync!['pending_data'] as Map) : null;

    return DriverModel(
      driverId: json['driver_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      alternativePhone: json['alternative_phone'],
      avatarUrl: json['avatar_url'],
      gender: json['gender'] ?? '',
      accountStatus: json['account_status'] ?? 'Pending',
      hasPendingChanges: metaSync?['has_pending_changes'] ?? false,
      pendingFullName: pendingData?['full_name'],
      pendingPhoneNumber: pendingData?['phone_number'],
      pendingEmail: pendingData?['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driver_id': driverId,
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'alternative_phone': alternativePhone,
      'avatar_url': avatarUrl,
      'gender': gender,
      'account_status': accountStatus,
      'has_pending_changes': hasPendingChanges,
      'pending_full_name': pendingFullName,
      'pending_phone_number': pendingPhoneNumber,
      'pending_email': pendingEmail,
    };
  }
}
