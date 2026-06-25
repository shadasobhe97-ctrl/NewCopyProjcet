import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/features/auth/data/models/login_request_model.dart';
import 'package:kids_transport/features/auth/data/models/reset_password_request_model.dart';
import 'package:kids_transport/features/auth/data/repositories/auth_repository.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit({AuthRepository? repository})
      : _repository = repository ?? AuthRepository(),
        super(AuthInitial());

  bool isPasswordObscured = true;

  void togglePasswordVisibility() {
    isPasswordObscured = !isPasswordObscured;
    emit(PasswordVisibilityChanged(isPasswordObscured));
  }

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final request = LoginRequestModel(
        phoneNumber: phone,
        password: password,
        deviceName: _deviceName,
        platform: _platform,
      );

      final response = await _repository.login(request);

      if (!response.status) {
        emit(AuthError(_fallbackMessage(response.message)));
        return;
      }

      emit(
        AuthSuccess(
          message: response.message,
          roleName: response.roleName.isNotEmpty
              ? response.roleName
              : _roleNameFromId(response.user.roleId),
          token: response.accessToken,
          roleId: response.user.roleId,
        ),
      );
    } on ApiException catch (error) {
      emit(AuthError(error.message));
    } catch (_) {
      emit(AuthError('فشل الاتصال بالخادم، يرجى المحاولة لاحقاً.'));
    }
  }

  Future<void> sendOtp({required String email}) async {
    emit(AuthLoading());
    try {
      final response = await _repository.sendOtp(email);

      if (response.status) {
        emit(OtpSentSuccess(message: response.message, email: email));
      } else {
        emit(AuthError(_fallbackMessage(response.message)));
      }
    } on ApiException catch (error) {
      emit(AuthError(error.message));
    } catch (_) {
      emit(AuthError('فشل الاتصال بالخادم.'));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    emit(AuthLoading());
    try {
      final request = ResetPasswordRequestModel(
        email: email,
        code: code,
        password: password,
        passwordConfirmation: confirmPassword,
      );

      final response = await _repository.resetPassword(request);

      if (response.status) {
        emit(PasswordResetSuccessState(response.message));
      } else {
        emit(AuthError(_fallbackMessage(response.message)));
      }
    } on ApiException catch (error) {
      emit(AuthError(error.message));
    } catch (_) {
      emit(AuthError('فشل الاتصال بالخادم.'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      final response = await _repository.logout();

      if (response.status) {
        emit(AuthLogoutSuccess(response.message));
      } else {
        emit(AuthError(_fallbackMessage(response.message)));
      }
    } on ApiException catch (error) {
      emit(AuthError(error.message));
    } catch (_) {
      emit(AuthError('فشل تسجيل الخروج، يرجى المحاولة مرة أخرى.'));
    }
  }

  String get _platform => kIsWeb ? 'web' : defaultTargetPlatform.name;

  String get _deviceName {
    if (kIsWeb) return 'Derbi_Flutter_Web';
    return 'Derbi_Flutter_${defaultTargetPlatform.name}';
  }

  String _roleNameFromId(int roleId) {
    if (roleId == 4) return 'سائق';
    if (roleId == 3) return 'ولي أمر';
    return '';
  }

  String _fallbackMessage(String message) {
    return message.isNotEmpty ? message : 'تعذر إكمال العملية.';
  }
}
