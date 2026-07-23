class ApiEndpoints {
  const ApiEndpoints._();

  // الرابط الأساسي للسيرفر (يحتوي على /api/)
  static const String baseUrl = 'http://127.0.0.1:8000/api/';

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
  static String parentChildSubscription(String id) =>
      'parent/children/$id/subscription';
  static const String parentSchools = 'parent/schools';
  static const String parentDriversSearch = 'parent/drivers/search';
  static const String parentSubscriptions = 'parent/subscriptions';

  static const String driverPreferences = 'v1/driver/preferences';
  static const String driverZones = 'v1/driver/zones';
  static const String driverProfile = 'v1/driver/profile';
  static const String driverProfileUpdate = 'v1/driver/profile/update';
  static const String parentProfile = 'parent/profile';
  static const String parentProfileUpdate = 'parent/profile/update';

  // Parent Subscriptions (تم التعديل)
  static const String parentRequests = 'parent/requests';
  static String parentRequestDetail(int id) => 'parent/requests/$id';
  static String parentRequestDelete(int id) => 'parent/$id';
  static String parentRequestCancel(int id) => 'parent/requests/$id/cancel';

  // Guardian Requests (API الجديد)
  static const String guardianRequests = 'guardian/requests';
  static String guardianRequestDetail(int id) => 'guardian/requests/$id';
  static String guardianRequestCancel(int id) => 'guardian/requests/$id/cancel';
  //طلب الاشتراك مع سوااق
  static const String parentrequestSubscription = 'parent';
  static const String parentActiveSubscriptions = 'parent/active-subscriptions';

  // Parent Wallet & Finance
  static const String parentWalletBalance = 'parent/wallet/balance';
  static const String parentWalletPaymentMethods =
      'parent/wallet/payment-methods';
  static const String parentWalletRecharge = 'parent/wallet/recharge';
  static const String parentInvoices = 'parent/invoices';
  static String parentInvoiceDetail(int id) => 'parent/invoices/$id';

  // Parent Trips & Live Tracking
  static const String parentActiveTrips = 'parent/trips/active';
  static String parentTripTrack(int id) => 'parent/trips/$id/track';
  static const String parentUpcomingTrips = 'parent/trips/upcoming';
  static const String parentTripHistory = 'parent/trips/history';

  // Parent Driver Reviews
  static String checkSubscription(int driverId) =>
      'parent/subscriptions/check?driver_id=$driverId';
  static const String driverReviews = 'parent/driver-reviews';
  static String getDriverReviews(int driverId) =>
      'parent/driver-reviews/driver/$driverId';
  static String driverReviewById(int reviewId) =>
      'parent/driver-reviews/$reviewId';

  // Parent Complaints
  static const String parentComplaints = 'parent/complaints';
  static String parentComplaintsByType(String type) =>
      'parent/complaints?type=$type';
  static String parentComplaintDetail(int id) => 'parent/complaints/$id';
  static String parentDriverTrips(int driverId) =>
      'parent/driver/$driverId/trips';
}
