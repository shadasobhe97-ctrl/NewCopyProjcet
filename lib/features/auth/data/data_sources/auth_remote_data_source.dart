import 'package:dio/dio.dart';
import '../models/login_request_model.dart';

class AuthRemoteDataSource {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://derbi-schools-api.loca.lt/api/'));

  // 1. تسجيل الدخول
  Future<Map<String, dynamic>> login(LoginRequestModel request) async {
    // ==================== [كود الربط الفعلي بالباكيند - محطوط كومنت] ====================
    /*
    final response = await _dio.post('auth/login', data: request.toJson());
    return response.data;
    */
    // =================================================================================

    // ---- [الوضع التجريبي الحالي: يحمل ثانيتين ويرجع بيانات وهمية مطابقة للباكيند] ----
    await Future.delayed(const Duration(seconds: 2));
    return {
      "status": true,
      "message": "مرحباً خالد مصطفى الورفلي، تم تسجيل الدخول بنجاح!",
      "access_token": "3|yj1MsGBh28EDGgZoKvb17ZkA88qZg7aEzUcovroO6899e4a5",
      "token_type": "Bearer",
      "role_name": "ولي أمر",
      "user": {
        "id": 10,
        "full_name": "خالد مصطفى الورفلي",
        "phone_number": request.phoneNumber,
        "role_id": 3,
        "is_active": true
      }
    };
  }

  // 2. تسجيل الخروج
  Future<Map<String, dynamic>> logout(String token) async {
    // ==================== [كود الربط الفعلي بالباكيند - محطوط كومنت] ====================
    /*
    final response = await _dio.post('auth/logout', 
      options: Options(headers: {'Authorization': 'Bearer $token'}));
    return response.data;
    */
    // =================================================================================

    await Future.delayed(const Duration(milliseconds: 500));
    return {"status": true, "message": "تم تسجيل الخروج بنجاح."};
  }

  // 3. إرسال رمز الـ OTP
  Future<Map<String, dynamic>> sendOtp(String email) async {
    // ==================== [كود الربط الفعلي بالباكيند - محطوط كومنت] ====================
    /*
    final response = await _dio.post('auth/password/send-otp', data: {'email': email});
    return response.data;
    */
    // =================================================================================

    await Future.delayed(const Duration(milliseconds: 600));
    return {"status": true, "message": "تم إرسال رمز التحقق إلى بريدك الإلكتروني."};
  }

  // 4. إعادة تعيين كلمة المرور
  Future<Map<String, dynamic>> resetPassword(Map<String, dynamic> data) async {
    // ==================== [كود الربط الفعلي بالباكيند - محطوط كومنت] ====================
    /*
    final response = await _dio.post('auth/password/reset', data: data);
    return response.data;
    */
    // =================================================================================

    await Future.delayed(const Duration(milliseconds: 800));
    return {"status": true, "message": "تم تحديث كلمة المرور بنجاح."};
  }
}