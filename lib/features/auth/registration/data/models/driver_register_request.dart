import 'dart:io';

class DriverRegisterRequest {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String gender; // male أو female
  final String password;
  final File? avatarFile; // ملف الصورة الشخصية الاختياري
  final String deviceName;
  final String platform; // ios, android, web
  final String fcmToken;
  final String? alternativePhone;

  DriverRegisterRequest({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    required this.password,
    this.avatarFile,
    required this.deviceName,
    required this.platform,
    required this.fcmToken,
    this.alternativePhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'gender': gender,
      'password': password,
      'device_name': deviceName,
      'platform': platform,
      'fcm_token': fcmToken,
      if (alternativePhone != null) 'alternative_phone': alternativePhone,
    };
  }
}