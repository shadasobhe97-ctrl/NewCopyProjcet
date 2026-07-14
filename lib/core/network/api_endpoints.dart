class ApiEndpoints {
  const ApiEndpoints._();

  // الرابط الأساسي للسيرفر (يحتوي على /api/)
  static const String baseUrl = 'https://darby-app-api.loca.lt/api/';

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
  static const String driverResendOtp = 'v1/driver/resend-otp';
  static const String driverVerifyOtp = 'v1/driver/verify-otp';
  static const String driverCompleteProfile = 'v1/driver/complete-profile';
  static const String driverPreferences = 'v1/driver/preferences';
  static const String driverZones = 'v1/driver/zones';

  //=========================================
  // Parent Registration endpoints (أولياء الأمور)
  //=========================================
  // POST /api/parent/send-otp  → إرسال OTP للبريد الإلكتروني
  static const String parentSendOtp = 'parent/send-otp';
  // POST /api/parent/register  → التسجيل النهائي (يحتوي على OTP)
  static const String parentRegister = 'parent/register';

  // مسارات إدارة العناوين (تتطلب Bearer token)
  static const String parentAddresses = 'parent/addresses';
  static String parentAddressById(String id) => 'parent/addresses/$id';

  // مسارات إدارة الأطفال والمدارس (تتطلب Bearer token)
  static const String parentChildren = 'parent/children';
  static String parentChildById(String id) => 'parent/children/$id';
  static String parentChildSubscription(String id) => 'parent/children/$id/subscription';
  static const String parentSchools = 'parent/schools';

  // مسار البحث عن السائقين وإرسال طلبات الاشتراك
  static const String parentDriversSearch = 'parent/drivers/search';
  static const String parentSubscriptions = 'parent';
}
