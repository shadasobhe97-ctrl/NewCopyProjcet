import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/admin/data/models/admin_user_model.dart';
import 'package:kids_transport/features/auth/data/models/login_request_model.dart';
import 'package:kids_transport/features/auth/data/repositories/auth_repository.dart';

class AdminAuthProvider with ChangeNotifier {
  final AuthRepository _repository;
  bool _isLoading = false;
  String? _errorMessage;
  AdminUserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AdminUserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  AdminAuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository() {
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
      final response = await _repository.login(
        LoginRequestModel(
          phoneNumber: phone,
          password: password,
          deviceName: _deviceName,
          platform: _platform,
        ),
      );

      if (!response.status) {
        _errorMessage = _fallbackMessage(response.message, 'بيانات الدخول غير صحيحة');
        return false;
      }

      if (!_isAdminRole(response.user.roleId)) {
        await StorageService.clearSession();
        _currentUser = null;
        _errorMessage = 'هذا الحساب ليس حساب مسؤول.';
        return false;
      }

      _currentUser = AdminUserModel(
        id: response.user.id.toString(),
        name: response.user.fullName,
        email: response.user.phoneNumber.isNotEmpty ? response.user.phoneNumber : phone,
        token: response.accessToken,
      );

      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ في الاتصال بالخادم';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // دالة تسجيل الخروج
  Future<bool> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.logout();
      if (!response.status) {
        _errorMessage = _fallbackMessage(response.message, 'فشل تسجيل الخروج.');
        return false;
      }

      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'فشل تسجيل الخروج، يرجى المحاولة مرة أخرى.';
      return false;
    } finally {
      await StorageService.clearSession();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isAdminRole(int roleId) => roleId > 0 && roleId != 3 && roleId != 4;

  String get _platform => kIsWeb ? 'web' : defaultTargetPlatform.name;

  String get _deviceName {
    if (kIsWeb) return 'Web_Admin_Panel';
    return 'Derbi_Admin_${defaultTargetPlatform.name}';
  }

  String _fallbackMessage(String message, String fallback) {
    return message.trim().isNotEmpty ? message : fallback;
  }
}
