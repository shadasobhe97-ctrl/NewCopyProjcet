abstract class AppEntryState {}

// الحالة الأولى عند فتح التطبيق (جاري التحقق)
class AppEntryInitial extends AppEntryState {}

// حالة التوجيه لشاشة العرض والتعريف (Onboarding)
class NavigateToOnboarding extends AppEntryState {}

// حالة التوجيه لشاشة تسجيل الدخول (Login)  
class NavigateToLogin extends AppEntryState {}

// حالة التوجيه لشاشة ولي الأمر الرئيسية
class NavigateToParentHome extends AppEntryState {}

// حالة التوجيه لشاشة السائق الرئيسية
class NavigateToDriverHome extends AppEntryState {}

// حالة التوجيه لشاشة الأدمن الرئيسية
class NavigateToAdminHome extends AppEntryState {}

// حالة التوجيه لشاشة انتظار السائق
class NavigateToDriverWaiting extends AppEntryState {}

// حالة التوجيه لشاشة تفضيلات السائق الإجبارية
class NavigateToDriverPreferencesRequired extends AppEntryState {}