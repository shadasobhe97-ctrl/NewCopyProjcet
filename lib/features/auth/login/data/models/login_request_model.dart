class LoginRequestModel {
  final String email;
  final String password;
  final String deviceName;
  final String platform;
  final String? fcmToken;

  LoginRequestModel({
    required this.email,
    required this.password,
    required this.deviceName,
    required this.platform,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'device_name': deviceName,
      'platform': platform,
      'fcm_token': fcmToken,
    };
  }
}