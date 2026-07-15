import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/features/admin/data/models/admin_user_model.dart';
import 'package:kids_transport/features/auth/login/data/models/login_request_model.dart';
import 'package:kids_transport/features/auth/login/data/repositories/auth_repository.dart';
import 'package:kids_transport/features/auth/login/data/repositories/session_repository.dart';
import 'admin_auth_state.dart';

export 'admin_auth_state.dart';

class AdminAuthCubit extends Cubit<AdminAuthState> {
  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;

  AdminAuthCubit(this._authRepository, this._sessionRepository)
      : super(_getInitialState(_sessionRepository));

  bool get isLoading => state.isLoading;
  String? get errorMessage => state.errorMessage;
  AdminUserModel? get currentUser => state.currentUser;
  bool get isAuthenticated => state.isAuthenticated;

  static AdminAuthState _getInitialState(SessionRepository repository) {
    final token = repository.getToken();
    final roleId = repository.getRoleId();
    final fullName = repository.getFullName();
    final phone = repository.getPhoneNumber();

    if (token != null && roleId != null && roleId != 3 && roleId != 4) {
      return AdminAuthState(
        currentUser: AdminUserModel(
          id: repository.getUserId() ?? '',
          name: fullName ?? 'المسؤول',
          email: phone ?? '',
          token: token,
        ),
      );
    }

    return const AdminAuthState();
  }

  Future<bool> login(String phone, String password) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final response = await _authRepository.login(
        LoginRequestModel(
          phoneNumber: phone,
          password: password,
          deviceName: _deviceName,
          platform: _platform,
        ),
      );

      if (!response.status) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: _fallbackMessage(
              response.message,
              'بيانات الدخول غير صحيحة',
            ),
          ),
        );
        return false;
      }

      if (!_isAdminRole(response.user.roleId)) {
        await _sessionRepository.clearSession();
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'هذا الحساب ليس حساب مسؤول.',
            clearUser: true,
          ),
        );
        return false;
      }

      emit(
        state.copyWith(
          isLoading: false,
          clearError: true,
          currentUser: AdminUserModel(
            id: response.user.id.toString(),
            name: response.user.fullName,
            email: response.user.phoneNumber.isNotEmpty
                ? response.user.phoneNumber
                : phone,
            token: response.accessToken,
          ),
        ),
      );

      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'حدث خطأ في الاتصال بالخادم',
        ),
      );
      return false;
    }
  }

  Future<bool> logout() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final response = await _authRepository.logout();
      if (!response.status) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: _fallbackMessage(
              response.message,
              'فشل تسجيل الخروج.',
            ),
          ),
        );
        return false;
      }

      emit(state.copyWith(isLoading: false, clearUser: true, clearError: true));
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage:
              'فشل تسجيل الخروج، يرجى المحاولة مرة أخرى.',
        ),
      );
      return false;
    } finally {
      await _sessionRepository.clearSession();
      emit(state.copyWith(isLoading: false, clearUser: true));
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
