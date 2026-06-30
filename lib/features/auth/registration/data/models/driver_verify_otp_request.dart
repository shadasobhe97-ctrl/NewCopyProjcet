class DriverVerifyOtpRequest {
  final String email;
  final String otp; // ريان طالباته كـ string في جسم الـ JSON بطول 6 أرقام بالضبط

  DriverVerifyOtpRequest({
    required this.email,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }
}