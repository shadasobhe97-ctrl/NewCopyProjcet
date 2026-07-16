import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/parent_model.dart';

class ParentProfileRemoteDataSource {
  final ApiClient _client;

  ParentProfileRemoteDataSource(this._client);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    if (token == null || token.isEmpty) return {};
    return {'Authorization': token};
  }

  void _checkSuccess(dynamic data, String fallbackMessage) {
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? fallbackMessage);
      }
    }
  }

  /// GET /api/parent/profile
  Future<ParentModel> getParentProfile() async {
    final response = await _client.get(
      ApiEndpoints.parentProfile,
      headers: _authHeader,
    );
    final data = response.data;
    debugPrint('📥 [ProfileAPI] GET /profile => $data');
    _checkSuccess(data, 'تعذر تحميل ملف ولي الأمر.');

    final payload = data is Map ? (data['data'] ?? data) : data;
    if (payload is! Map<String, dynamic>) {
      throw ApiException('استجابة غير متوقعة من السيرفر عند جلب الملف الشخصي.');
    }
    return ParentModel.fromJson(payload);
  }

  /// POST /api/parent/profile/update
  Future<ParentModel> updateParentProfile({
    required String fullName,
    required String phoneNumber,
    String? email,
    String? alternativePhone,
    File? avatarFile,
  }) async {
    debugPrint(
      '📤 [ProfileAPI] تحديث الملف: name=$fullName phone=$phoneNumber '
      'email=$email avatar=${avatarFile?.path}',
    );

    // الحقول الاختيارية نرسلها فقط إذا رغب المستخدم في تعديلها
    final fields = <String, dynamic>{
      'full_name': fullName,
      'phone_number': phoneNumber,
      if (email != null) 'email': email,
      'alternative_phone':
          alternativePhone, // ترسل null لحذفه كما طلبت الباك إند
    };

    final dynamic requestBody;
    if (avatarFile != null) {
      requestBody = FormData.fromMap({
        ...fields,
        // مطابقة الحقل مع الباك إند ليكون 'avatar'
        'avatar': await MultipartFile.fromFile(
          avatarFile.path,
          filename: avatarFile.path.split(Platform.pathSeparator).last,
        ),
      });
    } else {
      requestBody = fields;
    }

    final response = await _client.post(
      ApiEndpoints.parentProfileUpdate,
      headers: _authHeader,
      data: requestBody,
    );

    final data = response.data;
    debugPrint('📥 [ProfileAPI] POST /profile/update => $data');
    _checkSuccess(data, 'تعذر تحديث الملف الشخصي.');

    final payload = data is Map ? data['data'] : null;
    if (payload is Map<String, dynamic>) {
      return ParentModel.fromJson(payload);
    }

    debugPrint(
      '⚠️ [ProfileAPI] رد التحديث ما فيه كائن profile كامل، '
      'رح أجيب البيانات الطازجة من GET /profile بدل ما أفشل.',
    );
    return getParentProfile();
  }
}
