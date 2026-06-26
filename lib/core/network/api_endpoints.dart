class ApiEndpoints {
  const ApiEndpoints._();

  // الرابط الأساسي للسيرفر (يحتوي على /api/)
  static const String baseUrl = 'https://darby-api-new.loca.lt/api/';

  //=========================================
  // Auth Endpoints (مسارات المصادقة العامة)
  //=========================================
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String sendPasswordOtp = 'auth/password/send-otp';
  static const String verifyPasswordOtp = 'auth/password/verify-otp';
  static const String resetPassword = 'auth/password/reset';

  //=========================================
  // Driver Registration endpoints (السائقين)
  //=========================================
  // تتطابق مع بادئة الباك إند: api/v1/driver
  static const String driverRegister = 'v1/driver/register';
  static const String driverVerifyOtp = 'v1/driver/verify-otp';
  static const String driverCompleteProfile = 'v1/driver/complete-profile';

  //=========================================
  // Parent Registration endpoints (أولياء الأمور)
  //=========================================
  // تم تعديلها لتطابق تكرار الـ parent الناتج عن دمج app.php وملف routes
  static const String parentSendOtp = 'parent/parent/send-otp';
  static const String parentRegister = 'parent/parent/register';
  
  // مسار إدارة العناوين (يقع تحت الـ middleware المحمي داخل تجمع parent الثاني)
  static const String parentAddAddress = 'parent/parent/addresses';
}