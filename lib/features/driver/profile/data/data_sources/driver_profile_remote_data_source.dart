import 'dart:io';
import 'package:dio/dio.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/driver_model.dart';

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
  Future<DriverModel> updateDriverProfile({
    required String fullName,
    required String phoneNumber,
    String? alternativePhone,
    String? email,
    File? avatarFile,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'full_name': fullName,
        'phone_number': phoneNumber,
        if (alternativePhone != null) 'alternative_phone': alternativePhone,
        if (email != null) 'email': email,
      };

      if (avatarFile != null) {
        final fileName = avatarFile.path.split('/').last;
        dataMap['avatar'] = await MultipartFile.fromFile(
          avatarFile.path,
          filename: fileName,
        );
      }

      final formData = FormData.fromMap(dataMap);

      final response = await apiClient.post(
        ApiEndpoints.driverProfileUpdate,
        data: formData,
        headers: {
          'Accept': 'application/json',
          if (StorageService.getToken() != null)
            'Authorization': StorageService.getAuthorizationHeader(),
        },
      );

      if (response.statusCode == 200) {
        return DriverModel.fromJson(response.data['data']);
      } else {
        final errorMsg = response.data['message'] ?? 'فشل في تحديث البيانات';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data['message'] ?? 'فشل في تحديث البيانات';
      throw Exception(errorMsg);
    }
  }
}
