import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/terms_model.dart';

class TermsRemoteDataSource {
  final ApiClient _apiClient;

  TermsRemoteDataSource(this._apiClient);

  Future<TermsModel> getTerms({required String audience}) async {
    try {
      final endpoint = ApiEndpoints.termsCurrent(audience);
      final authHeader = StorageService.getAuthorizationHeader();

      final response = await _apiClient.dio.get(
        endpoint,
        options: authHeader != null
            ? Options(headers: {'Authorization': authHeader})
            : null,
      );

      final body = response.data;
      if (body is Map<String, dynamic>) {
        if (body['success'] == true && body['data'] != null) {
          return TermsModel.fromJson(Map<String, dynamic>.from(body['data']));
        } else if (body['data'] != null) {
          return TermsModel.fromJson(Map<String, dynamic>.from(body['data']));
        } else {
          throw ApiException(
            body['message']?.toString() ?? 'فشل جلب الشروط والأحكام.',
          );
        }
      }
      throw const ApiException('استجابة غير متوقعة من السيرفر.');
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('⚠️ خطأ عند جلب الشروط والأحكام: $e');
      throw ApiException('فشل جلب الشروط والأحكام: $e');
    }
  }

  Future<bool> acceptTerms({required int termsId}) async {
    try {
      final authHeader = StorageService.getAuthorizationHeader();
      final response = await _apiClient.post(
        ApiEndpoints.termsAccept,
        data: {'terms_id': termsId},
        headers: authHeader != null ? {'Authorization': authHeader} : null,
      );

      final body = response.data;
      if (body is Map<String, dynamic>) {
        if (body['success'] == true) {
          return true;
        } else {
          throw ApiException(
            body['message']?.toString() ?? 'فشل تأكيد الموافقة على الشروط.',
          );
        }
      }
      return true;
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('⚠️ خطأ عند الموافقة على الشروط: $e');
      throw ApiException('فشل الموافقة على الشروط والأحكام: $e');
    }
  }
}
