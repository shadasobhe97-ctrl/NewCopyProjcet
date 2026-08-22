import 'package:dio/dio.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/utils/app_image_helper.dart';
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
      final multipart = await AppImageHelper.createMultipartFile(
        request.avatarFile,
        defaultFilename: 'avatar.jpg',
      );
      if (multipart != null) {
        dataMap['avatar_url'] = multipart;
      }
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
    final rawType = data['type']?.toString().trim() ?? 'Bus';
    String normalizedType = 'Bus';
    if (rawType.toLowerCase() == 'sedan' || rawType.toLowerCase() == 'car') {
      normalizedType = 'Sedan';
    } else if (rawType.toLowerCase() == 'van') {
      normalizedType = 'Van';
    } else if (rawType.toLowerCase() == 'bus' || rawType.toLowerCase() == 'coach') {
      normalizedType = 'Bus';
    }
    formFields['type'] = normalizedType;
    formFields['capacity_manual'] = data['capacity_manual'] ?? 14;
    formFields['has_ac'] =
        (data['has_ac'] == true || data['has_ac'] == 1) ? 1 : 0;

    final Map<String, dynamic> filesMap = {};

    // 1. vehicle_image
    final vehicleImg = data['vehicle_image'] ?? data['vehicle_image_file'];
    if (vehicleImg != null) {
      final multipart = await AppImageHelper.createMultipartFile(
        vehicleImg,
        defaultFilename: 'vehicle.jpg',
      );
      if (multipart != null) filesMap['vehicle_image'] = multipart;
    }

    // 2. doc_license
    final licenseImg = data['doc_license'] ?? data['license_doc'];
    if (licenseImg != null) {
      final multipart = await AppImageHelper.createMultipartFile(
        licenseImg,
        defaultFilename: 'license.jpg',
      );
      if (multipart != null) filesMap['doc_license'] = multipart;
    }

    // 3. doc_logbook
    final logbookImg = data['doc_logbook'] ?? data['logbook_doc'];
    if (logbookImg != null) {
      final multipart = await AppImageHelper.createMultipartFile(
        logbookImg,
        defaultFilename: 'logbook.jpg',
      );
      if (multipart != null) filesMap['doc_logbook'] = multipart;
    }

    // 4. doc_insurance
    final insuranceImg = data['doc_insurance'] ?? data['insurance_doc'];
    if (insuranceImg != null) {
      final multipart = await AppImageHelper.createMultipartFile(
        insuranceImg,
        defaultFilename: 'insurance.jpg',
      );
      if (multipart != null) filesMap['doc_insurance'] = multipart;
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

  /// DELETE /api/v1/driver/abandon-registration
  Future<Map<String, dynamic>> cancelRegistration({
    required int userId,
    required String token,
  }) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.driverAbandonRegistration,
        data: {
          'user_id': userId,
        },
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return _mapResponse(response.data);
    } on ApiException catch (e) {
      return {'status': false, 'message': e.message};
    } catch (_) {
      return {'status': false, 'message': 'تم إلغاء التسجيل محلياً.'};
    }
  }

  Map<String, dynamic> _mapResponse(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ApiException('استجابة الخادم غير مفهومة.');
  }
}
