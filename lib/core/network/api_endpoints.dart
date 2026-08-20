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
  static const String driverStatus = 'v1/driver/status';

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

  static const String driverPreferenceDefaults =
      'v1/driver/preferences/defaults';
  static const String driverPreferences = 'v1/driver/preferences';
  static const String driverProfile = 'v1/driver/profile';
  static const String driverProfileUpdate = 'v1/driver/profile/update';
  static const String driverCancelEmailChange =
      'v1/driver/profile/email-change/cancel';
  static const String driverEmailChangeStatus =
      'v1/driver/profile/email-change/status';
  static const String driverLegalData = 'v1/driver/profile/legal-data';
  static const String driverVehicleProfile = 'v1/driver/profile/vehicle';
  static String driverVehicleUpdate(dynamic vehicleId) =>
      'v1/driver/profile/vehicle/$vehicleId';

  // ================= Driver Trips =================
  static const String driverTripsToday = 'v1/driver/trips/today';
  static String driverTripDetails(dynamic tripId) => 'v1/driver/trips/$tripId';
  static String driverTripStart(dynamic tripId) =>
      'v1/driver/trips/$tripId/start';
  static String driverTripLive(dynamic tripId) =>
      'v1/driver/trips/$tripId/live';
  static String driverTripLocation(dynamic tripId) =>
      'v1/driver/trips/$tripId/location';
  static String driverTripStops(dynamic tripId) =>
      'v1/driver/trips/$tripId/stops';
  static String driverTripChildStatus(dynamic tripId, dynamic tripChildId) =>
      'v1/driver/trips/$tripId/children/$tripChildId/status';
  static String driverTripSkipChild(dynamic tripId, dynamic childId) =>
      'v1/driver/trips/$tripId/skip/$childId';
  static String driverTripVerifyQr(dynamic tripId, dynamic childId) =>
      'v1/driver/trips/$tripId/verify-qr/$childId';
  static String driverTripComplete(dynamic tripId) =>
      'v1/driver/trips/$tripId/complete';
  static const String driverTripsHistory = 'v1/driver/trips/history';
  static String driverTripHistoryDetails(dynamic tripId) =>
      'v1/driver/trips/history/$tripId';
  static const String driverTripsRegisterAbsence =
      'v1/driver/trips/register-absence';
  static String driverTripReportBreakdown(dynamic tripId) =>
      'v1/driver/trips/$tripId/report-breakdown';
  static String driverTripResume(dynamic tripId) =>
      'v1/driver/trips/$tripId/resume';

  // ================= Driver Subscriptions =================
  static const String driverActiveSubscriptions = 'driver/active-subscriptions';
  static String driverSubscriptionDetails(int id) =>
      'driver/active-subscriptions/$id';

  static const String parentProfile = 'parent/profile';
  static const String parentProfileUpdate = 'parent/profile/update';
  static const String parentCancelEmailChange =
      'parent/profile/email-change/cancel';
  static const String parentEmailChangeStatus =
      'parent/profile/email-change/status';

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
  static String parentSubscriptionDetail(int id) =>
      'parent/active-subscriptions/$id';

  // Parent Wallet & Finance
  static const String parentWalletBalance = 'parent/wallet/balance';
  static const String parentWalletPaymentMethods =
      'parent/wallet/payment-methods';
  static const String parentWalletRecharge = 'parent/wallet/recharge';
  static const String parentWalletHoldTrip = 'parent/wallet/hold-trip';
  static String parentTripDispute(dynamic tripId) =>
      'parent/trips/$tripId/dispute';
  static const String parentInvoices = 'parent/invoices';
  static String parentInvoiceDetail(int id) => 'parent/invoices/$id';

  // Parent Trips & Live Tracking
  static const String parentActiveTrips = 'parent/trips/active';
  static String parentTripTrack(dynamic id) => 'parent/trips/$id/track';
  static const String parentMultipleActiveTracking =
      'parent/trips/active/tracking';
  static const String parentUpcomingTrips = 'parent/trips/upcoming';
  static const String parentTripHistory = 'parent/trips/history';
  static String parentTripDetails(dynamic id) => 'parent/trips/$id';
  static String parentTripTimeline(dynamic id) => 'parent/trips/$id/timeline';
  static String parentChildTrips(dynamic childId) =>
      'parent/children/$childId/trips';
  static String parentChildTripStatus(dynamic tripId, dynamic childId) =>
      'parent/trips/$tripId/children/$childId/status';

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

  // Parent Child Absence
  static String childAvailableAbsenceDates(int childId) =>
      'parent/children/$childId/available-absence-dates';
  static String childAbsences(int childId) =>
      'parent/children/$childId/absences';
  static String childSetAbsence(int childId) =>
      'parent/children/$childId/set-absence';
  static String childCancelAbsence(int childId) =>
      'parent/children/$childId/cancel-absence';

  // ================= Notifications & Device Tokens =================
  static const String registerDeviceToken = 'user/device-token';
  static const String deleteDeviceToken = 'user/device-token';
  static const String logoutAllDevices = 'user/device-token/logout-all';

  static const String notifications = 'notifications';
  static const String notificationsUnreadCount = 'notifications/unread-count';
  static String markNotificationRead(String id) => 'notifications/$id/read';
  static const String markAllNotificationsRead = 'notifications/read-all';
  static String deleteNotification(String id) => 'notifications/$id';
}
