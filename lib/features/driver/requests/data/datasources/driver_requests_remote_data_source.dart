import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/driver/requests/data/models/accept_request_response_model.dart';
import 'package:kids_transport/features/driver/requests/data/models/driver_request_model.dart';

class DriverRequestsRemoteDataSource {
  final ApiClient _apiClient;

  DriverRequestsRemoteDataSource(this._apiClient);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  /// GET /api/driver/requests — قائمة طلبات السائق (مع الترقيم)
  Future<PaginatedDriverRequests> fetchRequests({
    String? filter,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{'page': page};
    if (filter != null) {
      queryParams['filter'] = filter;
    }

    final response = await _apiClient.get(
      'driver/requests',
      queryParameters: queryParams,
      headers: _authHeader,
    );

    return parsePaginated(response.data);
  }

  /// يقرأ استجابة القائمة سواء جاء الترقيم داخل meta (العقد الحالي)
  /// أو في جذر الاستجابة (الشكل القديم).
  static PaginatedDriverRequests parsePaginated(dynamic data) {
    if (data == null) {
      return PaginatedDriverRequests(
        data: [],
        currentPage: 1,
        lastPage: 1,
        perPage: 15,
      );
    }

    if (data is Map) {
      // الباك يستخدم success في بعض المسارات و status في غيرها
      final ok = data['success'] ?? data['status'];
      if (ok == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل الطلبات.');
      }
    }

    List<dynamic> rawList = [];
    int currentPage = 1;
    int lastPage = 1;
    int perPage = 15;
    String? nextPageUrl;

    if (data is Map) {
      rawList = data['data'] is List ? data['data'] as List : const [];

      // الترقيم داخل meta في العقد الحالي
      final meta = data['meta'] is Map
          ? Map<String, dynamic>.from(data['meta'] as Map)
          : data;
      currentPage = _asInt(meta['current_page']) ?? 1;
      lastPage = _asInt(meta['last_page']) ?? 1;
      perPage = _asInt(meta['per_page']) ?? 15;

      // رابط الصفحة التالية داخل links في العقد الحالي
      final links = data['links'] is Map
          ? Map<String, dynamic>.from(data['links'] as Map)
          : null;
      nextPageUrl =
          links?['next']?.toString() ?? data['next_page_url']?.toString();
    } else if (data is List) {
      rawList = data;
    }

    final requests = rawList
        .whereType<Map>()
        .map((e) => DriverRequestModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return PaginatedDriverRequests(
      data: requests,
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPage,
      nextPageUrl: nextPageUrl,
    );
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  /// GET /api/driver/requests/{id} — تفاصيل طلب واحد.
  ///
  /// شكل هذا المسار يختلف عن القائمة: status ككائن، total_amount بدل
  /// total_price، وبيانات الطفل موزّعة على trip_details و subscription_period
  /// و pricing و school و home. الموديل يقرأ الشكلين.
  Future<DriverRequestModel> fetchRequestDetails(int requestId) async {
    final response = await _apiClient.get(
      'driver/requests/$requestId',
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      // الباك يستخدم success في بعض المسارات و status في غيرها
      final ok = data['success'] ?? data['status'];
      if (ok == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل تفاصيل الطلب.');
      }
      final requestData = data['data'] is Map
          ? Map<String, dynamic>.from(data['data'] as Map)
          : Map<String, dynamic>.from(data);
      return DriverRequestModel.fromJson(requestData);
    }
    throw const ApiException('تعذر تحميل تفاصيل الطلب.');
  }

  Future<AcceptRequestResponseModel> acceptRequest(int requestId) async {
    final response = await _apiClient.put(
      'driver/$requestId/status',
      data: {'status': 'accepted'},
      headers: _authHeader,
    );

    final data = response.data;
    if (data == null) {
      throw const ApiException('تعذر قبول الطلب.');
    }

    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر قبول الطلب.');
      }
      return AcceptRequestResponseModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw const ApiException('تعذر معالجة استجابة قبول الطلب.');
  }

  Future<void> rejectRequest(int requestId, {required String reason}) async {
    await _apiClient.put(
      'driver/$requestId/status',
      data: {'status': 'rejected', 'rejection_reason': reason},
      headers: _authHeader,
    );
  }
}
