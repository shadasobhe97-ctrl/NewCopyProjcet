class ApiEndpoints {
  const ApiEndpoints._();

  static const String baseUrl = 'https://darby-api-new.loca.lt/api/';

  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String sendPasswordOtp = 'auth/password/send-otp';
  static const String resetPassword = 'auth/password/reset';
}
