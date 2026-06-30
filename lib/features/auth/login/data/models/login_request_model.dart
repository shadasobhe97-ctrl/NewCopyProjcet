class LoginRequestModel {
  final String phoneNumber;
  final String password;
  final String deviceName;
  final String platform;

  LoginRequestModel({
    required this.phoneNumber,
    required this.password,
    required this.deviceName,
    required this.platform,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'password': password,
      'device_name': deviceName,
      'platform': platform,
    };
  }
}