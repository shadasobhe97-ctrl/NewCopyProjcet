abstract class AppEntryState {}

// الحالة الأولى عند فتح التطبيق (جاري التحقق)
class AppEntryInitial extends AppEntryState {}

// حالة التوجيه لشاشة العرض والتعريف (Onboarding)
class NavigateToOnboarding extends AppEntryState {}

// حالة التوجيه لشاشة تسجيل الدخول (Login)  
class NavigateToLogin extends AppEntryState {}

// حالة التوجيه لشاشة ولي الأمر الرئيسية
class NavigateToParentHome extends AppEntryState {}

// حالة التوجيه لشاشة تحديد موقع ولي الأمر عند استئناف التسجيل
class NavigateToParentLocationRequired extends AppEntryState {}

// حالة التوجيه لشاشة إضافة الطفل الأول عند استئناف التسجيل
class NavigateToParentChildRequired extends AppEntryState {}

// حالة التوجيه لشاشة السائق الرئيسية
class NavigateToDriverHome extends AppEntryState {}

// حالة التوجيه لشاشة الأدمن الرئيسية
class NavigateToAdminHome extends AppEntryState {}

// حالة التوجيه لشاشة انتظار السائق
class NavigateToDriverWaiting extends AppEntryState {}

// حالة التوجيه لشاشة تفضيلات السائق الإجبارية
class NavigateToDriverPreferencesRequired extends AppEntryState {}

// حالة التوجيه لاستئناف تسجيل السائق مع البيانات المحفوظة
class NavigateToResumeDriverRegistration extends AppEntryState {
  final String stage; // 'vehicle' أو 'docs'
  final Map<String, dynamic> draftData;

  NavigateToResumeDriverRegistration({
    required this.stage,
    required this.draftData,
  });
}