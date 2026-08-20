import 'dart:io';
import 'package:dio/dio.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import '../models/driver_register_request.dart';

class DriverRemoteDataSource {
  final ApiClient _apiClient;

  DriverRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// الخطوة 1: إرسال OTP لقاعدة البيانات والبريد
  /// POST /api/v1/driver/register
  Future<Map<String, dynamic>> register(DriverRegisterRequest request) async {
    final Map<String, dynamic> dataMap = request.toJson();
    if (request.avatarFile != null) {
      dataMap['avatar_url'] = await MultipartFile.fromFile(
        request.avatarFile!.path,
        filename: request.avatarFile!.path.split('/').last,
      );
    }

    final response = await _apiClient.post(
      ApiEndpoints.driverRegister,
      data: FormData.fromMap(dataMap),
    );
    return _mapResponse(response.data);
  }

  /// إعادة إرسال الرمز
  Future<Map<String, dynamic>> resendOtp(String email) async {
    final response = await _apiClient.post(
      ApiEndpoints.parentSendOtp,
      data: {'email': email},
    );
    return _mapResponse(response.data);
  }

  /// الخطوة 2: التحقق من OTP وإنشاء الحساب
  /// POST /api/v1/driver/verify-otp
  /// يستقبل جميع حقول الخطوة 1 + حقل otp
  Future<Map<String, dynamic>> verifyOtp(
    DriverRegisterRequest request,
    String otpCode,
  ) async {
    final Map<String, dynamic> dataMap = request.toJson();
    dataMap['otp'] = otpCode;

    if (request.avatarFile != null) {
      dataMap['avatar_url'] = await MultipartFile.fromFile(
        request.avatarFile!.path,
        filename: request.avatarFile!.path.split('/').last,
      );
    }

    final response = await _apiClient.post(
      ApiEndpoints.driverVerifyOtp,
      data: FormData.fromMap(dataMap),
    );
    return _mapResponse(response.data);
  }

  /// الخطوة 3: إكمال الملف (مركبة + وثائق)
  /// POST /api/v1/driver/complete-profile/{userId}
  Future<Map<String, dynamic>> completeProfile({
    required int userId,
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final Map<String, dynamic> formFields = {};

    formFields['national_id'] = data['national_id'] ?? '';
    formFields['license_number'] = data['license_number'] ?? '';
    formFields['license_expiry'] = data['license_expiry'] ?? '';
    formFields['insurance_expiry'] = data['insurance_expiry'] ?? '';
    formFields['plate_number'] = data['plate_number'] ?? '';
    formFields['brand'] = data['brand'] ?? '';
    formFields['model'] = data['model'] ?? '';
    formFields['year'] = data['year'] ?? 2023;
    formFields['color'] = data['color'] ?? '';
    formFields['type'] = data['type'] ?? 'Van';
    formFields['capacity_manual'] = data['capacity_manual'] ?? 14;
    formFields['has_ac'] =
        (data['has_ac'] == true || data['has_ac'] == 1) ? 1 : 0;

    final Map<String, dynamic> filesMap = {};

    // 1. vehicle_image
    if (data['vehicle_image'] is File) {
      final File file = data['vehicle_image'];
      filesMap['vehicle_image'] = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      );
    } else if (data['vehicle_image_file'] is File) {
      final File file = data['vehicle_image_file'];
      filesMap['vehicle_image'] = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      );
    }

    // 2. doc_license
    if (data['doc_license'] is File) {
      final File file = data['doc_license'];
      filesMap['doc_license'] = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      );
    } else if (data['license_doc'] is File) {
      final File file = data['license_doc'];
      filesMap['doc_license'] = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      );
    }

    // 3. doc_logbook
    if (data['doc_logbook'] is File) {
      final File file = data['doc_logbook'];
      filesMap['doc_logbook'] = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      );
    } else if (data['logbook_doc'] is File) {
      final File file = data['logbook_doc'];
      filesMap['doc_logbook'] = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      );
    }

    // 4. doc_insurance
    if (data['doc_insurance'] is File) {
      final File file = data['doc_insurance'];
      filesMap['doc_insurance'] = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      );
    } else if (data['insurance_doc'] is File) {
      final File file = data['insurance_doc'];
      filesMap['doc_insurance'] = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      );
    }

    final formData = FormData.fromMap({
      ...formFields,
      ...filesMap,
    });

    final response = await _apiClient.post(
      '${ApiEndpoints.driverCompleteProfile}/$userId',
      data: formData,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return _mapResponse(response.data);
  }

  /// GET /api/v1/driver/status
  Future<Map<String, dynamic>> checkDriverStatus(String token) async {
    final response = await _apiClient.get(
      ApiEndpoints.driverStatus,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return _mapResponse(response.data);
  }

  Map<String, dynamic> _mapResponse(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ApiException('استجابة الخادم غير مفهومة.');
  }
}
