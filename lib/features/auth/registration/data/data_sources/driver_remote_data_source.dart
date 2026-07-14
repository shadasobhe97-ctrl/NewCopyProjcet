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

  Future<Map<String, dynamic>> resendOtp(String email) async {
    final response = await _apiClient.post(
      ApiEndpoints.parentSendOtp,
      data: {'email': email},
    );
    return _mapResponse(response.data);
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otpCode) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverVerifyOtp,
      data: {
        'email': email,
        'otp': otpCode,
        'otp_code': otpCode,
      },
    );
    return _mapResponse(response.data);
  }

  Future<Map<String, dynamic>> completeProfile({
    required int userId,
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final Map<String, dynamic> formFields = {};
    
    // Extract plain fields
    formFields['national_id'] = data['national_id'] ?? data['driverNationalId'] ?? '';
    formFields['license_number'] = data['license_number'] ?? data['driverLicenseNumber'] ?? '';
    formFields['license_expiry'] = data['license_expiry'] ?? data['driverLicenseExpiry'] ?? '';
    formFields['brand'] = data['brand'] ?? '';
    formFields['model'] = data['model'] ?? '';
    formFields['year'] = data['year'] ?? 2023;
    formFields['color'] = data['color'] ?? '';
    formFields['type'] = data['type'] ?? 'Bus';
    formFields['capacity_manual'] = data['capacity_manual'] ?? 14;
    formFields['has_ac'] = data['has_ac'] ?? 1;
    if (data['alternative_phone'] != null) {
      formFields['alternative_phone'] = data['alternative_phone'];
    }

    final Map<String, dynamic> filesMap = {};

    // 1. doc_license
    if (data['license_doc'] is File) {
      final File file = data['license_doc'];
      filesMap['doc_license'] = await MultipartFile.fromFile(file.path, filename: file.path.split('/').last);
    }
    // 2. doc_criminal
    if (data['criminal_doc'] is File) {
      final File file = data['criminal_doc'];
      filesMap['doc_criminal'] = await MultipartFile.fromFile(file.path, filename: file.path.split('/').last);
      filesMap['doc_criminal_record'] = await MultipartFile.fromFile(file.path, filename: file.path.split('/').last);
    }
    // 3. doc_national_id (using logbook_doc as doc_national_id and doc_logbook)
    if (data['logbook_doc'] is File) {
      final File file = data['logbook_doc'];
      filesMap['doc_national_id'] = await MultipartFile.fromFile(file.path, filename: file.path.split('/').last);
      filesMap['doc_logbook'] = await MultipartFile.fromFile(file.path, filename: file.path.split('/').last);
    }
    if (data['insurance_doc'] is File) {
      final File file = data['insurance_doc'];
      filesMap['doc_insurance'] = await MultipartFile.fromFile(file.path, filename: file.path.split('/').last);
    }
    // 4. vehicle_image
    if (data['vehicle_image_file'] is File) {
      final File file = data['vehicle_image_file'];
      filesMap['vehicle_image'] = await MultipartFile.fromFile(file.path, filename: file.path.split('/').last);
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

  Map<String, dynamic> _mapResponse(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ApiException('استجابة الخادم غير مفهومة.');
  }
}
