import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';

class ChangePasswordRemoteDataSource {
  final ApiClient _apiClient;

  ChangePasswordRemoteDataSource(this._apiClient);

  Future<String> changePassword({
    required String oldPassword,
    required String password,
    required String passwordConfirmation,
    required bool isDriver,
  }) async {
    final endpoint = isDriver
        ? ApiEndpoints.driverChangePassword
        : ApiEndpoints.parentChangePassword;

    final authHeader = StorageService.getAuthorizationHeader();

    try {
      final response = await _apiClient.post(
        endpoint,
        headers: {
          'Accept': 'application/json',
          if (authHeader != null && authHeader.isNotEmpty)
            'Authorization': authHeader,
        },
        data: {
          'old_password': oldPassword,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final data = response.data;
      debugPrint('📥 [ChangePasswordAPI] POST $endpoint => $data');

      if (data is Map) {
        final success = data['success'] ?? data['status'];
        if (success == false) {
          final serverMessage = ApiException.extractMessage(data);
          throw ApiException(serverMessage ?? 'تعذر تغيير كلمة المرور.');
        }
        final msg = data['message'] ?? data['msg'];
        if (msg != null && msg.toString().isNotEmpty) {
          return msg.toString();
        }
      }
      return 'تم تغيير كلمة المرور بنجاح';
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final serverMessage = ApiException.extractMessage(e.response!.data);
        if (serverMessage != null && serverMessage.isNotEmpty) {
          throw ApiException(serverMessage);
        }
      }
      throw ApiException('حدث خطأ أثناء التواصل مع السيرفر. يرجى المحاولة لاحقاً.');
    }
  }
}
