import 'dart:io';
import 'package:dio/dio.dart';
import 'package:kids_transport/core/services/storage_service.dart';

class VehicleRemoteDataSource {
  final Dio _dio;

  final String baseUrl = 'https://darby-app-api.loca.lt/api/v1/';

  VehicleRemoteDataSource(this._dio);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  Future<Response> getVehicleData() async {
    return await _dio.get(
      '${baseUrl}driver/profile/vehicle',
      options: Options(headers: _authHeader),
    );
  }

  Future<Response> getLegalData() async {
    return await _dio.get(
      '${baseUrl}driver/profile/legal-data',
      options: Options(headers: _authHeader),
    );
  }

  Future<Response> updateVehicleDetails({
    required int vehicleId,
    required String brand,
    required String model,
    required int year,
    required String plateNumber,
    required int capacityManual,
    File? vehicleImage,
  }) async {
    Map<String, dynamic> data = {
      'brand': brand,
      'model': model,
      'year': year,
      'plate_number': plateNumber,
      'capacity_manual': capacityManual,
    };

    if (vehicleImage != null) {
      data['vehicle_image_url'] = await MultipartFile.fromFile(
        vehicleImage.path,
        filename: vehicleImage.path.split('/').last,
      );
    }

    return await _dio.post(
      '${baseUrl}driver/profile/vehicle/$vehicleId',
      data: FormData.fromMap(data),
      options: Options(headers: _authHeader),
    );
  }

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

    if (docLicense != null)
      data['doc_license'] = await MultipartFile.fromFile(docLicense.path);
    if (docLogbook != null)
      data['doc_logbook'] = await MultipartFile.fromFile(docLogbook.path);
    if (docInsurance != null)
      data['doc_insurance'] = await MultipartFile.fromFile(docInsurance.path);
    if (docCriminalRecord != null)
      data['doc_criminal_record'] = await MultipartFile.fromFile(
        docCriminalRecord.path,
      );

    return await _dio.post(
      '${baseUrl}driver/profile/legal-data',
      data: FormData.fromMap(data),
      options: Options(headers: _authHeader),
    );
  }
}
