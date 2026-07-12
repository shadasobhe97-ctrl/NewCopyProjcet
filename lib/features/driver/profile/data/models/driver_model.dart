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
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
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
    };
  }
}
