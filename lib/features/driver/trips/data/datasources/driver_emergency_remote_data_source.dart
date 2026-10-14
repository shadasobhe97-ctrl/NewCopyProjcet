import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/services/storage_service.dart';
import '../models/emergency_dispatch_model.dart';

class DriverEmergencyRemoteDataSource {
  final ApiClient _apiClient;

  DriverEmergencyRemoteDataSource(this._apiClient);

  Map<String, dynamic> get _authHeader {
    final auth = StorageService.getAuthorizationHeader();
    if (auth == null || auth.isEmpty) return {};
    return {'Authorization': auth};
  }

  /// 1. جلب المهام الطارئة المتاحة للسائق البديل
  /// GET /api/driver/emergency-dispatches/available
  Future<List<EmergencyDispatchModel>> getAvailableDispatches() async {
    List<Map<String, dynamic>> rawList = [];

    // المحاولة 1: استدعاء مسار المهام المتاحة الأساسي
    try {
      final response = await _apiClient.get(
        ApiEndpoints.driverEmergencyDispatchesAvailable,
        headers: _authHeader,
      );
      rawList = _extractDispatchesList(response.data);
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) rethrow;
    }

    // المحاولة 2: في حال كانت الاستجابة فارغة، تجربة بادئة v1 الاحتياطية
    if (rawList.isEmpty) {
      try {
        final response = await _apiClient.get(
          'v1/${ApiEndpoints.driverEmergencyDispatchesAvailable}',
          headers: _authHeader,
        );
        final list = _extractDispatchesList(response.data);
        if (list.isNotEmpty) {
          rawList = list;
        }
      } catch (_) {}
    }

    // المحاولة 3: في حال لم ترجع القائمة أي مهام وكان السائق قد استلم إشعاراً طارئاً مسبقاً
    if (rawList.isEmpty) {
      final recentId = StorageService.getLatestEmergencyDispatchId();
      if (recentId != null && recentId > 0) {
        try {
          final detail = await getDispatchDetails(recentId);
          if (detail.isBroadcasted) {
            return [detail];
          } else {
            await StorageService.clearLatestEmergencyDispatchId();
          }
        } catch (_) {
          await StorageService.clearLatestEmergencyDispatchId();
        }
      }
    }

    return rawList
        .map((e) => EmergencyDispatchModel.fromJson(e))
        .toList();
  }

  /// تفريغ واستخراج قائمة المهام بمرونة فائقة لمختلف أشكال استجابات Laravel والباك إند
  List<Map<String, dynamic>> _extractDispatchesList(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (data is Map) {
      final status = data['status']?.toString();
      if (status == 'error') {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر جلب المهام الطارئة المتاحة.');
      }

      final innerData = data['data'];

      // 1. مصفوفة مباشرة تحت data['data']
      if (innerData is List) {
        return innerData
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      // 2. كائن متداخل تحت data['data'] (كاستجابات Pagination أو التغليف)
      if (innerData is Map) {
        if (innerData['data'] is List) {
          return (innerData['data'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        if (innerData['dispatches'] is List) {
          return (innerData['dispatches'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        if (innerData['available_dispatches'] is List) {
          return (innerData['available_dispatches'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        if (innerData['emergency_dispatches'] is List) {
          return (innerData['emergency_dispatches'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        if (innerData['items'] is List) {
          return (innerData['items'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        if (innerData['records'] is List) {
          return (innerData['records'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        if (innerData['results'] is List) {
          return (innerData['results'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }

        // في حال كان innerData يمثل مهمة طارئة واحدة مباشرة
        if (innerData.containsKey('id') || innerData.containsKey('trip_id')) {
          return [Map<String, dynamic>.from(innerData)];
        }
      }

      // 3. مفاتيح المستوى الأول داخل data
      if (data['dispatches'] is List) {
        return (data['dispatches'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      if (data['available_dispatches'] is List) {
        return (data['available_dispatches'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      if (data['emergency_dispatches'] is List) {
        return (data['emergency_dispatches'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      if (data['items'] is List) {
        return (data['items'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      // 4. كائن مهمة واحدة بالمستوى الأول
      if (data['dispatch'] is Map) {
        return [Map<String, dynamic>.from(data['dispatch'] as Map)];
      }
      if (data['emergency_dispatch'] is Map) {
        return [Map<String, dynamic>.from(data['emergency_dispatch'] as Map)];
      }
      if (data['available_dispatch'] is Map) {
        return [Map<String, dynamic>.from(data['available_dispatch'] as Map)];
      }

      // 5. في حال كانت استجابة الـ Map هي كائن البلاغ مباشرة
      if (data.containsKey('id') &&
          (data.containsKey('trip_id') ||
              data.containsKey('status') ||
              data.containsKey('original_driver'))) {
        return [Map<String, dynamic>.from(data)];
      }
    }

    return [];
  }

  /// 2. استعراض تفاصيل المهمة الطارئة والطلاب والمسار المتبقي
  /// GET /api/driver/emergency-dispatches/{dispatchId}
  Future<EmergencyDispatchModel> getDispatchDetails(int dispatchId) async {
    final response = await _apiClient.get(
      ApiEndpoints.driverEmergencyDispatchDetails(dispatchId),
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final status = data['status']?.toString();
      if (status == 'error') {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر جلب تفاصيل المهمة الطارئة.');
      }
      final dispatchData = data['data'] is Map
          ? Map<String, dynamic>.from(data['data'] as Map)
          : (data['dispatch'] is Map
              ? Map<String, dynamic>.from(data['dispatch'] as Map)
              : (data['available_dispatch'] is Map
                  ? Map<String, dynamic>.from(data['available_dispatch'] as Map)
                  : (data['emergency_dispatch'] is Map
                      ? Map<String, dynamic>.from(data['emergency_dispatch'] as Map)
                      : Map<String, dynamic>.from(data))));

      return EmergencyDispatchModel.fromJson(dispatchData);
    }

    throw const ApiException('تعذر جلب تفاصيل المهمة الطارئة.');
  }

  /// 3. قبول المهمة الطارئة من السائق البديل
  /// POST /api/driver/emergency-dispatches/{dispatchId}/accept
  Future<Map<String, dynamic>> acceptDispatch(int dispatchId) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverEmergencyDispatchAccept(dispatchId),
      headers: _authHeader,
    );

    await StorageService.clearLatestEmergencyDispatchId();

    final data = response.data;
    if (data is Map) {
      final status = data['status']?.toString();
      if (status == 'error') {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر قبول المهمة الطارئة.');
      }
      return Map<String, dynamic>.from(data);
    }

    return {'status': 'success'};
  }

  /// 4. رفض المهمة الطارئة من السائق البديل
  /// POST /api/driver/emergency-dispatches/{dispatchId}/reject
  Future<Map<String, dynamic>> rejectDispatch(int dispatchId) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverEmergencyDispatchReject(dispatchId),
      headers: _authHeader,
    );

    await StorageService.clearLatestEmergencyDispatchId();

    final data = response.data;
    if (data is Map) {
      final status = data['status']?.toString();
      if (status == 'error') {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر رفض المهمة الطارئة.');
      }
      return Map<String, dynamic>.from(data);
    }

    return {'status': 'success'};
  }
}
