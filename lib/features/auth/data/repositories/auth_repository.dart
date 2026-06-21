import 'package:kids_transport/features/auth/data/models/auth_common_response_model.dart';

import '../data_sources/auth_remote_data_source.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/reset_password_request_model.dart';

class AuthRepository {
  final AuthRemoteDataSource _dataSource = AuthRemoteDataSource();

  // تمرير الـ Model بالكامل ديناميكياً للـ DataSource
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final responseData = await _dataSource.login(request);
    return LoginResponseModel.fromJson(responseData);
  }

  Future<Map<String, dynamic>> logout(String token) async {
    return await _dataSource.logout(token);
  }

  // إرسال رمز الـ OTP (معدلة لترجع الموديل الموحد)
  Future<AuthCommonResponseModel> sendOtp(String email) async {
    final responseData = await _dataSource.sendOtp(email);
    return AuthCommonResponseModel.fromJson(responseData);
  }

  // إعادة تعيين كلمة المرور (معدلة لترجع الموديل الموحد)
  Future<AuthCommonResponseModel> resetPassword(
    ResetPasswordRequestModel request,
  ) async {
    final responseData = await _dataSource.resetPassword(request.toJson());
    return AuthCommonResponseModel.fromJson(responseData);
  }
}
