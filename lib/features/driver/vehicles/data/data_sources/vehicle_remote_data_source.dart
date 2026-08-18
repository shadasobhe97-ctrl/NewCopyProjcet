import 'dart:io';
import 'package:dio/dio.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/services/storage_service.dart';

class VehicleRemoteDataSource {
  final ApiClient _apiClient;

  VehicleRemoteDataSource(this._apiClient);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {
      'Authorization': token ?? '',
      'Accept': 'application/json',
    };
  }

  /// 1. GET /api/v1/driver/profile/vehicle
  Future<Response> getVehicleData() async {
    return await _apiClient.get(
      ApiEndpoints.driverVehicleProfile,
      headers: _authHeader,
    );
  }

  /// GET /api/v1/driver/profile/legal-data
  Future<Response> getLegalData() async {
    return await _apiClient.get(
      ApiEndpoints.driverLegalData,
      headers: _authHeader,
    );
  }

  /// 2. POST /api/v1/driver/profile/vehicle/{vehicleId}
  Future<Response> updateVehicleDetails({
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
    final Map<String, dynamic> data = {};
    if (brand != null && brand.isNotEmpty) data['brand'] = brand;
    if (model != null && model.isNotEmpty) data['model'] = model;
    if (year != null) data['year'] = year;
    if (plateNumber != null && plateNumber.isNotEmpty) data['plate_number'] = plateNumber;
    if (color != null && color.isNotEmpty) data['color'] = color;
    if (type != null && type.isNotEmpty) data['type'] = type;
    if (capacityManual != null) data['capacity_manual'] = capacityManual;
    if (hasAc != null) data['has_ac'] = hasAc;

    if (vehicleImage != null) {
      data['vehicle_image_path'] = await MultipartFile.fromFile(
        vehicleImage.path,
        filename: vehicleImage.path.split('/').last.split('\\').last,
      );
    }

    return await _apiClient.post(
      ApiEndpoints.driverVehicleUpdate(vehicleId),
      data: FormData.fromMap(data),
      headers: _authHeader,
    );
  }

  /// POST /api/v1/driver/profile/legal-data
  Future<Response> updateLegalData({
    required String nationalId,
    required String licenseNumber,
    required String licenseExpiry,
    File? docLicense,
    File? docLogbook,
    File? docInsurance,
    File? docCriminalRecord,
  }) async {
    Map<String, dynamic> data = {
      'national_id': nationalId,
      'license_number': licenseNumber,
      'license_expiry_date': licenseExpiry,
    };

    if (docLicense != null) {
      data['doc_license'] = await MultipartFile.fromFile(docLicense.path);
    }
    if (docLogbook != null) {
      data['doc_logbook'] = await MultipartFile.fromFile(docLogbook.path);
    }
    if (docInsurance != null) {
      data['doc_insurance'] = await MultipartFile.fromFile(docInsurance.path);
    }
    if (docCriminalRecord != null) {
      data['doc_criminal_record'] = await MultipartFile.fromFile(
        docCriminalRecord.path,
      );
    }

    return await _apiClient.post(
      ApiEndpoints.driverLegalData,
      data: FormData.fromMap(data),
      headers: _authHeader,
    );
  }
}
