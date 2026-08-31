import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/driver_statistics_model.dart';

class DriverStatisticsRemoteDataSource {
  final ApiClient _apiClient;

  DriverStatisticsRemoteDataSource(this._apiClient);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  Future<DriverStatisticsModel> getDriverStatistics({
    int? month,
    int? year,
  }) async {
    final queryParams = <String, dynamic>{};
    if (month != null && month >= 1 && month <= 12) {
      queryParams['month'] = month;
    }
    if (year != null && year > 2000) {
      queryParams['year'] = year;
    }

    final response = await _apiClient.get(
      ApiEndpoints.driverStatistics,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      headers: _authHeader,
    );

    final data = _handleResponse(response.data);
    final statsData = data['data'] as Map<String, dynamic>? ?? data;
    return DriverStatisticsModel.fromJson(statsData);
  }

  Map<String, dynamic> _handleResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'حدث خطأ في جلب إحصائيات السائق.');
      }
      return data;
    }
    throw const ApiException('استجابة غير متوقعة من الخادم.');
  }
}
