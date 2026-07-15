import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/features/auth/login/data/models/auth_common_response_model.dart';
import 'package:kids_transport/features/auth/login/data/repositories/session_repository.dart';

import '../data_sources/auth_remote_data_source.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/reset_password_request_model.dart';

class AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final SessionRepository _sessionRepository;

  AuthRepository(this._dataSource, this._sessionRepository);

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final responseData = await _dataSource.login(request);
    final response = LoginResponseModel.fromJson(responseData);

    if (response.status) {
      if (response.accessToken.isEmpty || response.user.roleId == 0) {
        throw const ApiException('بيانات الجلسة الراجعة من الخادم غير مكتملة.');
      }

      await _sessionRepository.saveUserSession(
        token: response.accessToken,
        tokenType: response.tokenType,
        roleId: response.user.roleId,
        roleName: response.roleName,
        userId: response.user.id,
        fullName: response.user.fullName,
        phoneNumber: response.user.phoneNumber,
        isActive: response.user.isActive,
      );
    }

    return response;
  }

  Future<AuthCommonResponseModel> logout() async {
    final authorizationHeader = _sessionRepository.getAuthorizationHeader();

    if (authorizationHeader == null) {
      await _sessionRepository.clearSession();
      return const AuthCommonResponseModel(
        status: true,
        message: 'تم تسجيل الخروج بنجاح.',
      );
    }

    try {
      final responseData = await _dataSource.logout(authorizationHeader);
      return AuthCommonResponseModel.fromJson(responseData);
    } finally {
      await _sessionRepository.clearSession();
    }
  }

  Future<AuthCommonResponseModel> sendOtp(String email) async {
    final responseData = await _dataSource.sendOtp(email);
    return AuthCommonResponseModel.fromJson(responseData);
  }

  Future<AuthCommonResponseModel> verifyOtp(String email, String code) async {
    final responseData = await _dataSource.verifyOtp(email, code);
    return AuthCommonResponseModel.fromJson(responseData);
  }

  Future<AuthCommonResponseModel> resetPassword(
    ResetPasswordRequestModel request,
  ) async {
    final responseData = await _dataSource.resetPassword(request);
    return AuthCommonResponseModel.fromJson(responseData);
  }
}
