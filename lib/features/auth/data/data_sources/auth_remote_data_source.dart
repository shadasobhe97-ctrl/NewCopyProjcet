import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';

import '../models/login_request_model.dart';
import '../models/reset_password_request_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> login(LoginRequestModel request) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    return _mapResponse(response.data);
  }

  Future<Map<String, dynamic>> logout(String authorizationHeader) async {
    final response = await _apiClient.post(
      ApiEndpoints.logout,
      headers: {'Authorization': authorizationHeader},
    );
    return _mapResponse(response.data);
  }

  Future<Map<String, dynamic>> sendOtp(String email) async {
    final response = await _apiClient.post(
      ApiEndpoints.sendPasswordOtp,
      data: {'email': email},
    );
    return _mapResponse(response.data);
  }

  Future<Map<String, dynamic>> resetPassword(
    ResetPasswordRequestModel request,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.resetPassword,
      data: request.toJson(),
    );
    return _mapResponse(response.data);
  }

  Map<String, dynamic> _mapResponse(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ApiException('استجابة الخادم غير مفهومة.');
  }
}
