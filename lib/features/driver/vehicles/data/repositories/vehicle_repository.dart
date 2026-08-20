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
      final vehicleResponse = await remoteDataSource.getVehicleData();
      final vehicleData = (vehicleResponse.data is Map && vehicleResponse.data['data'] != null)
          ? vehicleResponse.data['data']
          : {};

      Map<String, dynamic> mergedData = Map<String, dynamic>.from(vehicleData as Map);

      try {
        final legalResponse = await remoteDataSource.getLegalData();
        final legalData = (legalResponse.data is Map && legalResponse.data['data'] != null)
            ? legalResponse.data['data']
            : {};
        if (legalData is Map) {
          mergedData['national_id'] = legalData['national_id'];
          mergedData['license_number'] = legalData['license_number'];
          mergedData['license_expiry'] = legalData['license_expiry'];
        }
      } catch (_) {}

      return VehicleModel.fromJson(mergedData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  // 📤 تحديث تفاصيل المركبة
  Future<VehicleModel> updateVehicle({
    required int vehicleId,
    String? brand,
    String? model,
    int? year,
    String? plateNumber,
    String? color,
    String? type,
    int? capacityManual,
    bool? hasAc,
    File? vehicleImage,
  }) async {
    try {
      final response = await remoteDataSource.updateVehicleDetails(
        vehicleId: vehicleId,
        brand: brand,
        model: model,
        year: year,
        plateNumber: plateNumber,
        color: color,
        type: type,
        capacityManual: capacityManual,
        hasAc: hasAc,
        vehicleImage: vehicleImage,
      );
      final data = (response.data is Map && response.data['data'] != null)
          ? response.data['data']
          : {};
      return VehicleModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  // 📤 تحديث المستندات والوثائق
  Future<String> updateLegalData({
    String? nationalId,
    String? licenseNumber,
    String? licenseExpiry,
    String? insuranceExpiry,
    File? docLicense,
    File? docLogbook,
    File? docInsurance,
  }) async {
    try {
      final response = await remoteDataSource.updateLegalData(
        nationalId: nationalId,
        licenseNumber: licenseNumber,
        licenseExpiry: licenseExpiry,
        insuranceExpiry: insuranceExpiry,
        docLicense: docLicense,
        docLogbook: docLogbook,
        docInsurance: docInsurance,
      );
      return response.data['message'] ?? 'تم تحديث الوثائق بنجاح';
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<String> updateLegalDocuments({
    String? nationalId,
    String? licenseNumber,
    String? licenseExpiry,
    String? insuranceExpiry,
    File? docLicense,
    File? docLogbook,
    File? docInsurance,
  }) =>
      updateLegalData(
        nationalId: nationalId,
        licenseNumber: licenseNumber,
        licenseExpiry: licenseExpiry,
        insuranceExpiry: insuranceExpiry,
        docLicense: docLicense,
        docLogbook: docLogbook,
        docInsurance: docInsurance,
      );

  String _handleDioError(DioException e) {
    if (e.response?.data is Map && e.response?.data['message'] != null) {
      return e.response!.data['message'].toString();
    }
    if (e.response?.statusCode == 422) {
      return 'البيانات المرسلة غير مطابقة لشروط النظام.';
    }
    return 'حدث خطأ في الاتصال بالسيرفر، تأكد من اتصال الإنترنت.';
  }
}
