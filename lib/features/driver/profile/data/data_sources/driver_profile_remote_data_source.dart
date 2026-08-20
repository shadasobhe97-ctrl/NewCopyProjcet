import 'dart:io';
import 'package:dio/dio.dart';
import 'package:kids_transport/core/models/email_verification_info.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/driver_model.dart';
import '../models/driver_legal_data_model.dart';

class DriverProfileRemoteDataSource {
  final ApiClient apiClient;

  DriverProfileRemoteDataSource({required this.apiClient});

  // 1. جلب بيانات الملف الشخصي للسائق
  Future<DriverModel> getDriverProfile() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.driverProfile,
        headers: {
          'Accept': 'application/json',
          if (StorageService.getToken() != null)
            'Authorization': StorageService.getAuthorizationHeader(),
        },
      );

      if (response.statusCode == 200) {
        return DriverModel.fromJson(response.data['data']);
      } else {
        throw Exception('فشل في جلب بيانات الحساب من السيرفر');
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['message'] ?? 'فشل في جلب بيانات الحساب من السيرفر';
      throw Exception(errorMsg);
    }
  }

  // 2. تحديث البيانات الشخصية والمظهر (POST) باستخدام Multipart/FormData
  Future<ProfileUpdateResult<DriverModel>> updateDriverProfile({
    String? fullName,
    String? phoneNumber,
    String? alternativePhone,
    String? email,
    File? avatarFile,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {};
      if (fullName != null && fullName.trim().isNotEmpty) {
        dataMap['full_name'] = fullName.trim();
      }
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        dataMap['phone_number'] = phoneNumber.trim();
      }
      if (alternativePhone != null && alternativePhone.trim().isNotEmpty) {
        dataMap['alternative_phone'] = alternativePhone.trim();
      }
      if (email != null && email.trim().isNotEmpty) {
        dataMap['email'] = email.trim();
      }

      if (avatarFile != null) {
        final fileName = avatarFile.path.split('/').last;
        dataMap['avatar'] = await MultipartFile.fromFile(
          avatarFile.path,
          filename: fileName,
        );
      }

      final formData = FormData.fromMap(dataMap);

      final response = await apiClient.put(
        ApiEndpoints.driverProfileUpdate,
        data: formData,
        headers: {
          'Accept': 'application/json',
          if (StorageService.getToken() != null)
            'Authorization': StorageService.getAuthorizationHeader(),
        },
      );

      if (response.statusCode == 200) {
        EmailVerificationInfo? emailVerification;
        if (response.data is Map &&
            response.data['data'] is Map &&
            response.data['data']['email_verification'] is Map) {
          emailVerification = EmailVerificationInfo.fromJson(
            Map<String, dynamic>.from(
              response.data['data']['email_verification'] as Map,
            ),
          );
        }

        final driver = DriverModel.fromJson(response.data['data']);
        final message =
            (response.data is Map && response.data['message'] != null)
            ? response.data['message'].toString()
            : 'تم تحديث ملفك الشخصي بنجاح';

        return ProfileUpdateResult<DriverModel>(
          profile: driver,
          emailVerification: emailVerification,
          message: message,
        );
      } else {
        final errorMsg = response.data['message'] ?? 'فشل في تحديث البيانات';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data['message'] ?? 'فشل في تحديث البيانات';
      throw Exception(errorMsg);
    }
  }

  // 3. إلغاء تغيير البريد الإلكتروني (POST)
  Future<void> cancelEmailChange() async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.driverCancelEmailChange,
        headers: {
          'Accept': 'application/json',
          if (StorageService.getToken() != null)
            'Authorization': StorageService.getAuthorizationHeader(),
        },
      );

      if (response.statusCode != 200) {
        final errorMsg =
            response.data['message'] ?? 'فشل في إلغاء تغيير البريد الإلكتروني';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['message'] ?? 'فشل في إلغاء تغيير البريد الإلكتروني';
      throw Exception(errorMsg);
    }
  }

  // 4. فحص حالة تغيير البريد الإلكتروني (GET)
  Future<String> getEmailChangeStatus() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.driverEmailChangeStatus,
        headers: {
          'Accept': 'application/json',
          if (StorageService.getToken() != null)
            'Authorization': StorageService.getAuthorizationHeader(),
        },
      );

      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['data'] is Map) {
        return (response.data['data']['status'] ?? '').toString();
      } else {
        final errorMsg =
            response.data['message'] ??
            'فشل في فحص حالة تغيير البريد الإلكتروني';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['message'] ??
          'فشل في فحص حالة تغيير البريد الإلكتروني';
      throw Exception(errorMsg);
    }
  }

  // 5. جلب الوثائق والبيانات الرسمية (GET)
  Future<DriverLegalDataModel> getLegalData() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.driverLegalData,
        headers: {
          'Accept': 'application/json',
          if (StorageService.getToken() != null)
            'Authorization': StorageService.getAuthorizationHeader(),
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data['data'] ?? response.data;
        return DriverLegalDataModel.fromJson(
          Map<String, dynamic>.from(data as Map),
        );
      } else {
        final errorMsg = _extractApiErrorMessage(
          response.data,
          'فشل في جلب الوثائق الرسمية',
        );
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      final errorMsg = _extractApiErrorMessage(
        e.response?.data,
        e.message ?? 'فشل في جلب الوثائق الرسمية',
      );
      throw Exception(errorMsg);
    }
  }

  // 6. تحديث الوثائق والبيانات الرسمية (POST Multipart)
  Future<DriverLegalDataModel> updateLegalData({
    String? nationalId,
    String? licenseNumber,
    String? licenseExpiry,
    String? insuranceExpiry,
    Map<String, File>? newFiles,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {};
      if (nationalId != null && nationalId.trim().isNotEmpty) {
        dataMap['national_id'] = nationalId.trim();
      }
      if (licenseNumber != null && licenseNumber.trim().isNotEmpty) {
        dataMap['license_number'] = licenseNumber.trim();
      }
      if (licenseExpiry != null && licenseExpiry.trim().isNotEmpty) {
        dataMap['license_expiry'] = licenseExpiry.trim();
      }
      if (insuranceExpiry != null && insuranceExpiry.trim().isNotEmpty) {
        dataMap['insurance_expiry'] = insuranceExpiry.trim();
      }

      if (newFiles != null && newFiles.isNotEmpty) {
        for (final entry in newFiles.entries) {
          final file = entry.value;
          final fileName = file.path.split('/').last.split('\\').last;
          final multipartFile = await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          );
          
          final docTypeKey = entry.key.toUpperCase();
          String apiKey = entry.key;
          if (docTypeKey == 'LICENSE') apiKey = 'doc_license';
          if (docTypeKey == 'VEHICLE_LOGBOOK') apiKey = 'doc_logbook';
          if (docTypeKey == 'INSURANCE') apiKey = 'doc_insurance';

          dataMap[apiKey] = multipartFile;
        }
      }

      final formData = FormData.fromMap(dataMap);

      final response = await apiClient.post(
        ApiEndpoints.driverLegalData,
        data: formData,
        headers: {
          'Accept': 'application/json',
          if (StorageService.getToken() != null)
            'Authorization': StorageService.getAuthorizationHeader(),
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data['data'] ?? response.data;
        return DriverLegalDataModel.fromJson(
          Map<String, dynamic>.from(data as Map),
        );
      } else {
        final errorMsg = _extractApiErrorMessage(
          response.data,
          'فشل في إرسال طلب تعديل الوثائق',
        );
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      final errorMsg = _extractApiErrorMessage(
        e.response?.data,
        e.message ?? 'فشل في إرسال طلب تعديل الوثائق',
      );
      throw Exception(errorMsg);
    }
  }

  String _extractApiErrorMessage(dynamic data, String defaultMsg) {
    if (data is Map) {
      if (data['message'] != null && data['message'].toString().isNotEmpty) {
        return data['message'].toString();
      }
      if (data['error'] != null && data['error'].toString().isNotEmpty) {
        return data['error'].toString();
      }
      if (data['errors'] != null) {
        final errors = data['errors'];
        if (errors is Map) {
          final messages = errors.values
              .expand((element) => element is List ? element : [element])
              .join('\n');
          if (messages.isNotEmpty) return messages;
        }
      }
    }
    return defaultMsg;
  }
}
