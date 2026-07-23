import 'package:dio/dio.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/complaint_model.dart';
import '../models/driver_trip_model.dart';

class ComplaintsRemoteDataSource {
  final ApiClient _client;

  ComplaintsRemoteDataSource(this._client);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  /// GET /api/parent/complaints or /api/parent/complaints?type={type}
  Future<List<ComplaintModel>> getComplaints({String? type}) async {
    final endpoint = (type != null && type.isNotEmpty && type != 'all')
        ? ApiEndpoints.parentComplaintsByType(type)
        : ApiEndpoints.parentComplaints;

    final response = await _client.get(
      endpoint,
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر جلب قائمة الشكاوى');
      }
      final rawList = data['data'] as List<dynamic>? ?? data['complaints'] as List<dynamic>? ?? [];
      return rawList.map((e) => ComplaintModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } else if (data is List) {
      return data.map((e) => ComplaintModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }
    return [];
  }

  /// GET /api/parent/complaints/{id}
  Future<ComplaintModel> getComplaintDetails(int id) async {
    final response = await _client.get(
      ApiEndpoints.parentComplaintDetail(id),
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final item = data['data'] is Map ? data['data'] : data;
      return ComplaintModel.fromJson(Map<String, dynamic>.from(item as Map));
    }
    throw const ApiException('تعذر جلب تفاصيل الشكوى');
  }

  /// POST /api/parent/complaints
  Future<ComplaintModel> createComplaint({
    required int driverId,
    required int tripId,
    required String description,
  }) async {
    final response = await _client.post(
      ApiEndpoints.parentComplaints,
      data: {
        'driver_id': driverId,
        'trip_id': tripId,
        'description': description,
      },
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر إرسال الشكوى');
      }
      final item = data['data'] is Map ? data['data'] : data;
      return ComplaintModel.fromJson(Map<String, dynamic>.from(item as Map));
    }
    throw const ApiException('تعذر تقديم الشكوى');
  }

  /// POST /api/parent/complaints/{id}
  Future<ComplaintModel> updateComplaint({
    required int id,
    required String description,
    int? tripId,
  }) async {
    final body = <String, dynamic>{
      'description': description,
    };
    if (tripId != null) {
      body['trip_id'] = tripId;
    }

    final response = await _client.post(
      ApiEndpoints.parentComplaintDetail(id),
      data: body,
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تعديل الشكوى');
      }
      final item = data['data'] is Map ? data['data'] : data;
      return ComplaintModel.fromJson(Map<String, dynamic>.from(item as Map));
    }
    throw const ApiException('تعذر تعديل الشكوى');
  }

  /// DELETE /api/parent/complaints/{id}
  Future<void> deleteComplaint(int id) async {
    final response = await _client.delete(
      ApiEndpoints.parentComplaintDetail(id),
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر حذف الشكوى');
      }
    }
  }

  /// GET /api/parent/driver/{driverId}/trips
  Future<List<DriverTripModel>> getDriverTrips(int driverId) async {
    final response = await _client.get(
      ApiEndpoints.parentDriverTrips(driverId),
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final rawList = data['data'] as List<dynamic>? ?? data['trips'] as List<dynamic>? ?? [];
      return rawList.map((e) => DriverTripModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } else if (data is List) {
      return data.map((e) => DriverTripModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }
    return [];
  }
}
