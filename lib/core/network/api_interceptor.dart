import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/main.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 1. إضافة الـ Authorization Header تلقائياً من StorageService إذا لم يتم تمريره يدوياً
    final tokenHeader = StorageService.getAuthorizationHeader();
    if (tokenHeader != null && tokenHeader.isNotEmpty) {
      if (!options.headers.containsKey('Authorization') ||
          options.headers['Authorization'] == null ||
          (options.headers['Authorization'] as String).isEmpty) {
        options.headers['Authorization'] = tokenHeader;
      }
    }

    // 2. طباعة مفصلة ودقيقة لكل طلب API حسب شروط المراجعة
    final fullUrl = options.path.startsWith('http')
        ? options.path
        : '${options.baseUrl}${options.path}';
    final authHeader = options.headers['Authorization']?.toString();
    final hasAuth = authHeader != null && authHeader.isNotEmpty;

    debugPrint('\n=================== 🌐 API REQUEST LOG ===================');
    debugPrint('➡️ HTTP Method : ${options.method.toUpperCase()}');
    debugPrint('🔗 Request URL : $fullUrl');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('❓ Query Params : ${options.queryParameters}');
    }
    debugPrint('🔑 Authorization Header Sent : ${hasAuth ? "YES (نعم)" : "NO (لا)"}');
    if (hasAuth) {
      debugPrint('   • Authorization Token : $authHeader');
    }
    debugPrint('📋 Request Headers:');
    options.headers.forEach((key, value) {
      debugPrint('   • $key: $value');
    });
    if (options.data != null) {
      debugPrint('📦 Request Body: ${options.data}');
    }
    debugPrint('=========================================================\n');

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final fullUrl = response.requestOptions.path.startsWith('http')
        ? response.requestOptions.path
        : '${response.requestOptions.baseUrl}${response.requestOptions.path}';

    debugPrint('\n=================== ✅ API RESPONSE LOG ===================');
    debugPrint('📥 URL         : $fullUrl');
    debugPrint('🔢 Status Code : ${response.statusCode}');
    debugPrint('📄 Response Body: ${response.data}');
    debugPrint('=========================================================\n');

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    final statusCode = response?.statusCode;
    final fullUrl = err.requestOptions.path.startsWith('http')
        ? err.requestOptions.path
        : '${err.requestOptions.baseUrl}${err.requestOptions.path}';

    debugPrint('\n=================== ❌ API ERROR LOG ===================');
    debugPrint('⚠️ URL         : $fullUrl');
    debugPrint('🔢 Status Code : $statusCode');
    debugPrint('💬 Error Type   : ${err.type}');
    debugPrint('📄 Response Body: ${response?.data}');
    debugPrint('========================================================\n');

    // 🌟 معالجة استجابة 401 Unauthorized (Unauthenticated) تلقائياً
    if (statusCode == 401) {
      debugPrint('🚨 [AUTH ERROR 401]: الـ Token غير صالح أو ملغى من السيرفر! جاري مسح الجلسة وتوجيه المستخدم لشاشة تسجيل الدخول...');
      _handleUnauthenticated();
    }

    super.onError(err, handler);
  }

  static bool _isHandlingUnauth = false;

  void _handleUnauthenticated() async {
    if (_isHandlingUnauth) return;
    _isHandlingUnauth = true;

    try {
      await StorageService.clearSession();
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    } catch (e) {
      debugPrint('❌ Error navigating to login on 401: $e');
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        _isHandlingUnauth = false;
      });
    }
  }
}
