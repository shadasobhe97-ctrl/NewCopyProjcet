import 'dart:io';

class ParentRegisterRequest {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? alternativePhone;
  final String password;
  final String passwordConfirmation;
  final int otp;
  final String? deviceName;
  final String? platform;
  final String? fcmToken;
  final File? avatar;

  ParentRegisterRequest({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.alternativePhone,
    required this.password,
    required this.passwordConfirmation,
    required this.otp,
    this.deviceName,
    this.platform,
    this.fcmToken,
    this.avatar,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      if (alternativePhone != null && alternativePhone!.isNotEmpty)
        'alternative_phone': alternativePhone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'otp': otp,
      if (deviceName != null && deviceName!.isNotEmpty)
        'device_name': deviceName,
      if (platform != null && platform!.isNotEmpty) 'platform': platform,
      if (fcmToken != null && fcmToken!.isNotEmpty) 'fcm_token': fcmToken,
    };
  }
}
