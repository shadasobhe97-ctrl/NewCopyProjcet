import 'dart:io';
import 'package:dio/dio.dart';
import '../data_sources/vehicle_remote_data_source.dart';
import '../models/vehicle_model.dart';

class VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  VehicleRepository(this.remoteDataSource);

  // 📥 جلب تفاصيل المركبة والوثائق معاً ودمجهم في الـ Model
  Future<VehicleModel> getVehicleDetails() async {
    try {
      // إرسال الطلبين في نفس الوقت لتوفير الوقت
      final vehicleResponse = await remoteDataSource.getVehicleData();
      final legalResponse = await remoteDataSource.getLegalData();

      final vehicleData = vehicleResponse.data['data'];
      final legalData = legalResponse.data['data'];

      // دمج بيانات المسارين داخل كائن الـ VehicleModel واحد لترتاح الواجهة
      return VehicleModel.fromJson({
        ...vehicleData,
        'national_id': legalData['national_id'],
        'license_number': legalData['license_number'],
        'license_expiry': legalData['license_expiry'],
      });
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 📤 تحديث تفاصيل المركبة
  Future<VehicleModel> updateVehicle({
    required int vehicleId,
    required String brand,
    required String model,
    required int year,
    required String plateNumber,
    required int capacityManual,
    File? vehicleImage,
  }) async {
    try {
      final response = await remoteDataSource.updateVehicleDetails(
        vehicleId: vehicleId,
        brand: brand,
        model: model,
        year: year,
        plateNumber: plateNumber,
        capacityManual: capacityManual,
        vehicleImage: vehicleImage,
      );
      return VehicleModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 📤 تحديث المستندات والوثائق
  Future<String> updateLegalDocuments({
    required String nationalId,
    required String licenseNumber,
    required String licenseExpiry,
    File? docLicense,
    File? docLogbook,
    File? docInsurance,
    File? docCriminalRecord,
  }) async {
    try {
      final response = await remoteDataSource.updateLegalData(
        nationalId: nationalId,
        licenseNumber: licenseNumber,
        licenseExpiry: licenseExpiry,
        docLicense: docLicense,
        docLogbook: docLogbook,
        docInsurance: docInsurance,
        docCriminalRecord: docCriminalRecord,
      );
      return response.data['message'] ?? 'تم تحديث الوثائق بنجاح';
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    if (e.response?.statusCode == 422) {
      return e.response?.data['message'] ??
          'البيانات المرسلة غير مطابقة لشروط النظام.';
    }
    return 'حدث خطأ في الاتصال بالسيرفر، تأكد من اتصال الإنترنت.';
  }
}
