import 'dart:io';

class DriverRegisterRequest {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String gender; // male أو female
  final String password;
  final File? avatarFile; // ملف الصورة الشخصية الاختياري
  final String deviceName;
  final String platformName;

  DriverRegisterRequest({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    required this.password,
    this.avatarFile,
    required this.deviceName,
    required this.platformName,
  });

  // الدالة هادي تجهز البيانات لتُرسل كـ FormData للـ Dio
  Map<String, dynamic> toFormDataMap() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'gender': gender,
      'password': password,
      'device_name': deviceName,
      'platform_name': platformName,
    };
  }
}