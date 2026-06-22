import 'package:flutter/material.dart';
import 'package:kids_transport/features/admin/data/models/admin_user_model.dart';
// import 'package:dio/dio.dart'; // مكتبة الـ API سيتم تفعيلها لاحقاً

class AdminAuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  AdminUserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AdminUserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  // دالة تسجيل الدخول
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ---------------------------------------------------------
      // الكود الفعلي للربط مع السيرفر (API) - سيتم تفعيله لاحقاً
      // ---------------------------------------------------------
      /*
      final dio = Dio();
      final response = await dio.post(
        'https://api.copyproject.com/admin/login', // ضع الرابط الفعلي هنا
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        _currentUser = AdminUserModel.fromJson(response.data['user']);
        // يجب حفظ التوكن في التخزين المحلي باستخدام SharedPreferences
        // await StorageService.saveToken(_currentUser!.token);
      } else {
        _errorMessage = 'بيانات الدخول غير صحيحة';
      }
      */
      
      // ---------------------------------------------------------
      // محاكاة (Mocking) للبيانات لغرض التجربة الحالية
      // ---------------------------------------------------------
      await Future.delayed(const Duration(seconds: 2)); // محاكاة التأخير الزمني للسيرفر
      
      if (email == 'admin@copyproject.com' && password == 'admin123') {
        _currentUser = AdminUserModel(
          id: '1',
          name: 'المسؤول الرئيسي',
          email: email,
          token: 'mock_token_12345',
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ في الاتصال بالخادم';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // دالة تسجيل الخروج
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    // ---------------------------------------------------------
    // كود السيرفر لإنهاء الجلسة (API) - سيتم تفعيله لاحقاً
    // ---------------------------------------------------------
    /*
    try {
      final dio = Dio();
      // تأكد من تمرير التوكن في الـ Headers
      await dio.post('https://api.copyproject.com/admin/logout', 
        options: Options(headers: {'Authorization': 'Bearer ${_currentUser?.token}'})
      );
    } catch(e) {
      debugPrint('خطأ أثناء تسجيل الخروج من السيرفر: $e');
    }
    // مسح التوكن من التخزين المحلي
    // await StorageService.clearToken();
    */

    // تنظيف الحالات وإلغاء الجلسة محلياً
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
