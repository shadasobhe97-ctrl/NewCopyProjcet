import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  // دالة تهيئة الـ SharedPreferences عند تشغيل التطبيق أول مرة
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // مفاتيح التخزين الثابتة (Keys) لمنع الأخطاء الإملائية
  static const String _themeKey = 'is_dark_mode';
  
  // 🌟 توحيد المفاتيح هنا باش تطابق الـ Responses متع الباكيند وماتضربش الـ Session
  static const String _tokenKey = 'token';
  static const String _roleIdKey = 'role_id';
  static const String _isFirstTimeKey = 'is_first_time';

  /// ─── إدارة حالة الثيم (Theme Management) ───

  // دالة حفظ وضع الثيم (فاتح أو غامق)
  static Future<bool> saveThemeMode(bool isDarkMode) async {
    return await _prefs.setBool(_themeKey, isDarkMode);
  }

  // دالة قراءة وضع الثيم الحالي (الافتراضي فاتح false إذا لم يُحفظ شيء بعد)
  static bool getThemeMode() {
    return _prefs.getBool(_themeKey) ?? false;
  }

  /// ─── إدارة بيانات المستخدم والـ Session ───

  // جلب التوكن الحقيقي للمستخدم
  static String? getToken() => _prefs.getString(_tokenKey);

  // جلب الـ ID المخزن لدور المستخدم (2 أو 3)
  static String? getRoleId() {
    return _prefs.getString(_roleIdKey);
  }

  // دالة حفظ الجلسة الموحدة بالـ ID والتوكن بعد تسجيل الدخول بنجاح
  static Future<void> saveUserSession({required String token, required int roleId}) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_roleIdKey, roleId.toString()); // نحولوه لـ String باش يتخزن بأمان في الكاش
  }

  // مسح البيانات كاملة وتصفية الكاش عند تسجيل الخروج
  static Future<void> clearSession() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_roleIdKey);
  }

  /// ─── إدارة حالة الأونبوردينق (Onboarding) ───

  // دالة لحفظ أن المستخدم خلاص شاف الـ Onboarding وتخطاها
  static Future<void> setFirstTimeComplete() async {
    await _prefs.setBool(_isFirstTimeKey, false);
  }

  // دالة تفحص هل هي أول مرة يفتح فيها التطبيق؟ (لو مالقاش قيمة حيرجع true تلقائياً)
  static bool isFirstTime() => _prefs.getBool(_isFirstTimeKey) ?? true;
}