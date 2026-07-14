class ParentRegisterRequest {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? alternativePhone;
  final String password;
  final String passwordConfirmation;
  final int otp;
  final String deviceName;
  final String platform;
  final String? fcmToken;

  ParentRegisterRequest({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.alternativePhone,
    required this.password,
    required this.passwordConfirmation,
    required this.otp,
    required this.deviceName,
    required this.platform,
    this.fcmToken,
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
      'device_name': deviceName,
      'platform': platform,
      if (fcmToken != null && fcmToken!.isNotEmpty) 'fcm_token': fcmToken,
    };
  }
}
