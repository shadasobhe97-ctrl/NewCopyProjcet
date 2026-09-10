import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/services/storage_service.dart';
import '../models/location_change_options_model.dart';
import '../models/location_change_preview_model.dart';
import '../models/location_change_request_model.dart';

class LocationChangeRemoteDataSource {
  final ApiClient _apiClient;

  LocationChangeRemoteDataSource(this._apiClient);

  Map<String, dynamic> get _authHeader {
    final auth = StorageService.getAuthorizationHeader();
    if (auth == null || auth.isEmpty) return {};
    return {'Authorization': auth};
  }

  Future<LocationChangeOptionsModel> getOptions() async {
    final response = await _apiClient.get(
      ApiEndpoints.parentLocationChangeOptions,
      headers: _authHeader,
    );
    return LocationChangeOptionsModel.fromJson(response.data);
  }

  Future<LocationChangePreviewModel> previewRequest(Map<String, dynamic> body) async {
    final response = await _apiClient.post(
      ApiEndpoints.parentLocationChangePreview,
      data: body,
      headers: _authHeader,
    );
    return LocationChangePreviewModel.fromJson(response.data);
  }

  Future<LocationChangeRequestModel> createRequest(Map<String, dynamic> body) async {
    final response = await _apiClient.post(
      ApiEndpoints.parentLocationChangeRequests,
      data: body,
      headers: _authHeader,
    );
    final data = response.data['data'] is Map ? response.data['data'] as Map<String, dynamic> : response.data;
    return LocationChangeRequestModel.fromJson(data);
  }

  Future<List<LocationChangeRequestModel>> getRequests() async {
    final response = await _apiClient.get(
      ApiEndpoints.parentLocationChangeRequests,
      headers: _authHeader,
    );
    final data = response.data['data'];
    final list = data is List ? data : (response.data is List ? response.data : []);
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => LocationChangeRequestModel.fromJson(e))
        .toList();
  }
}
