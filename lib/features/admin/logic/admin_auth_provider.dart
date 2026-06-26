import 'package:flutter/material.dart';
import 'package:kids_transport/features/admin/data/models/admin_user_model.dart';
import 'package:dio/dio.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';

class AdminAuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  AdminUserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AdminUserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  AdminAuthProvider() {
    _loadSession();
  }

  void _loadSession() {
    final token = StorageService.getToken();
    final roleId = StorageService.getRoleId();
    final fullName = StorageService.getFullName();
    final phone = StorageService.getPhoneNumber();
    if (token != null && roleId != null && roleId != 3 && roleId != 4) {
      _currentUser = AdminUserModel(
        id: StorageService.getUserId()?.toString() ?? '',
        name: fullName ?? 'المسؤول',
        email: phone ?? '',
        token: token,
      );
    }
  }

  // دالة تسجيل الدخول
  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      final response = await dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.login}',
        data: {
          'phone_number': phone,
          'email': phone,
          'password': password,
          'device_name': 'Web_Admin_Panel',
          'platform': 'web',
        },
      );

      final data = response.data;
      if (data != null && data['status'] == true) {
        final token = data['access_token'] ?? '';
        final userJson = data['user'] ?? {};
        final fullName = userJson['full_name'] ?? '';
        final userPhone = userJson['phone_number'] ?? '';
        final roleIdRaw = userJson['role_id'];
        final roleId = roleIdRaw is int ? roleIdRaw : int.tryParse(roleIdRaw.toString()) ?? 1;
        final roleName = data['role_name'] ?? 'أدمن';

        _currentUser = AdminUserModel(
          id: userJson['id']?.toString() ?? '',
          name: fullName,
          email: phone,
          token: token,
        );

        await StorageService.saveUserSession(
          token: token,
          roleId: roleId,
          roleName: roleName,
          userId: userJson['id'] is int ? userJson['id'] : int.tryParse(userJson['id'].toString()),
          fullName: fullName,
          phoneNumber: userPhone,
          isActive: userJson['is_active'] == true || userJson['is_active'] == 1,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data != null ? data['message'] ?? 'بيانات الدخول غير صحيحة' : 'بيانات الدخول غير صحيحة';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        _errorMessage = data['message'].toString();
      } else if (data is Map && data['errors'] != null) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstValue = errors.values.first;
          if (firstValue is List && firstValue.isNotEmpty) {
            _errorMessage = firstValue.first.toString();
          } else {
            _errorMessage = firstValue.toString();
          }
        } else {
          _errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        }
      } else {
        _errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      }
      _isLoading = false;
      notifyListeners();
      return false;
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

    try {
      final token = StorageService.getToken();
      if (token != null) {
        final dio = Dio();
        await dio.post(
          '${ApiEndpoints.baseUrl}${ApiEndpoints.logout}',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
      }
    } catch (e) {
      debugPrint('خطأ أثناء تسجيل الخروج من السيرفر: $e');
    } finally {
      await StorageService.clearSession();
      _currentUser = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    }
  }
}
