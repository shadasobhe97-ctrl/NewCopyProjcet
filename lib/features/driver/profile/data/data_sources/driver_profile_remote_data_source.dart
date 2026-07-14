import 'package:dio/dio.dart';
// عدلي المسار حسب مجلد الـ core عندكِ
import 'package:kids_transport/core/network/api_endpoints.dart';
import '../models/driver_model.dart';

class DriverProfileRemoteDataSource {
  final Dio dio; // تغيير النوع من http.Client إلى Dio

  DriverProfileRemoteDataSource({required this.dio});

  // 1. جلب بيانات الملف الشخصي للسائق
  Future<DriverModel> getDriverProfile() async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}driver/profile',
        options: Options(
          headers: {
            'Accept': 'application/json',
            // 'Authorization': 'Bearer YOUR_TOKEN_HERE', // مرري التوكن هنا لو المسار محمي
          },
        ),
      );

      if (response.statusCode == 200) {
        // Dio يقوم بعمل الـ decode تلقائياً، نستخدم response.data مباشرة
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

  // 2. تحديث البيانات الشخصية والمظهر (POST)
  Future<DriverModel> updateDriverProfile({
    required String fullName,
    required String phoneNumber,
    String? alternativePhone,
    String? email,
  }) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.baseUrl}profile/update',
        options: Options(
          headers: {
            'Accept': 'application/json',
            // 'Authorization': 'Bearer YOUR_TOKEN_HERE',
          },
        ),
        // في Dio نمرر الخريطة (Map) مباشرة إلى data بدون jsonEncode
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
          'alternative_phone': alternativePhone,
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        return DriverModel.fromJson(response.data['data']);
      }
      {
        final errorMsg = response.data['message'] ?? 'فشل في تحديث البيانات';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data['message'] ?? 'فشل في تحديث البيانات';
      throw Exception(errorMsg);
    }
  }
}
