import 'package:dio/dio.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/core/utils/app_image_helper.dart';

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
    dynamic vehicleImage,
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
      final multipart = await AppImageHelper.createMultipartFile(
        vehicleImage,
        defaultFilename: 'vehicle.jpg',
      );
      if (multipart != null) {
        data['vehicle_image_path'] = multipart;
        data['vehicle_image'] = multipart;
      }
    }

    return await _apiClient.post(
      ApiEndpoints.driverVehicleUpdate(vehicleId),
      data: FormData.fromMap(data),
      headers: _authHeader,
    );
  }

  /// POST /api/v1/driver/profile/legal-data
  Future<Response> updateLegalData({
    String? nationalId,
    String? licenseNumber,
    String? licenseExpiry,
    String? insuranceExpiry,
    dynamic docLicense,
    dynamic docLogbook,
    dynamic docInsurance,
  }) async {
    Map<String, dynamic> data = {};

    if (nationalId != null && nationalId.isNotEmpty) {
      data['national_id'] = nationalId;
    }
    if (licenseNumber != null && licenseNumber.isNotEmpty) {
      data['license_number'] = licenseNumber;
    }
    if (licenseExpiry != null && licenseExpiry.isNotEmpty) {
      data['license_expiry'] = licenseExpiry;
    }
    if (insuranceExpiry != null && insuranceExpiry.isNotEmpty) {
      data['insurance_expiry'] = insuranceExpiry;
    }

    if (docLicense != null) {
      final multipart = await AppImageHelper.createMultipartFile(
        docLicense,
        defaultFilename: 'license.jpg',
      );
      if (multipart != null) data['doc_license'] = multipart;
    }
    if (docLogbook != null) {
      final multipart = await AppImageHelper.createMultipartFile(
        docLogbook,
        defaultFilename: 'logbook.jpg',
      );
      if (multipart != null) data['doc_logbook'] = multipart;
    }
    if (docInsurance != null) {
      final multipart = await AppImageHelper.createMultipartFile(
        docInsurance,
        defaultFilename: 'insurance.jpg',
      );
      if (multipart != null) data['doc_insurance'] = multipart;
    }

    return await _apiClient.post(
      ApiEndpoints.driverLegalData,
      data: FormData.fromMap(data),
      headers: _authHeader,
    );
  }
}
