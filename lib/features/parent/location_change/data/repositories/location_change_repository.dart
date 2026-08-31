import 'package:dio/dio.dart';
import '../datasources/location_change_remote_data_source.dart';
import '../models/location_change_options_model.dart';
import '../models/location_change_preview_model.dart';
import '../models/location_change_request_model.dart';

class BatchPreviewResult {
  final List<LocationChangePreviewModel> previews;
  final List<String> errors;

  BatchPreviewResult({
    required this.previews,
    required this.errors,
  });
}

class BatchSubmitResult {
  final List<LocationChangeRequestModel> createdRequests;
  final List<String> errors;

  BatchSubmitResult({
    required this.createdRequests,
    required this.errors,
  });
}

class LocationChangeRepository {
  final LocationChangeRemoteDataSource _remoteDataSource;

  LocationChangeRepository(this._remoteDataSource);

  Future<LocationChangeOptionsModel> getOptions() async {
    return await _remoteDataSource.getOptions();
  }

  Future<BatchPreviewResult> previewBatch({
    required List<int> activeSubscriptionIds,
    required String pointType,
    int? addressId,
    double? lat,
    double? lng,
    String? label,
    String? changeDate,
  }) async {
    final List<LocationChangePreviewModel> previews = [];
    final List<String> errors = [];

    for (final subId in activeSubscriptionIds) {
      final body = <String, dynamic>{
        'active_subscription_id': subId,
        'point_type': pointType,
        if (addressId != null) 'address_id': addressId,
        if (addressId == null && lat != null && lng != null) ...{
          'lat': lat,
          'lng': lng,
        },
        if (label != null && label.isNotEmpty) 'label': label,
        if (changeDate != null && changeDate.isNotEmpty) 'change_date': changeDate,
      };

      try {
        final preview = await _remoteDataSource.previewRequest(body);
        previews.add(preview);
      } on DioException catch (e) {
        final msg = e.response?.data is Map && e.response?.data['message'] != null
            ? e.response!.data['message'].toString()
            : 'حدث خطأ في حساب المعاينة';
        errors.add(msg);
      } catch (e) {
        errors.add(e.toString());
      }
    }

    return BatchPreviewResult(previews: previews, errors: errors);
  }

  Future<BatchSubmitResult> submitBatch({
    required List<int> activeSubscriptionIds,
    required String pointType,
    int? addressId,
    double? lat,
    double? lng,
    String? label,
    String? changeDate,
  }) async {
    final List<LocationChangeRequestModel> createdRequests = [];
    final List<String> errors = [];

    for (final subId in activeSubscriptionIds) {
      final body = <String, dynamic>{
        'active_subscription_id': subId,
        'point_type': pointType,
        if (addressId != null) 'address_id': addressId,
        if (addressId == null && lat != null && lng != null) ...{
          'lat': lat,
          'lng': lng,
        },
        if (label != null && label.isNotEmpty) 'label': label,
        if (changeDate != null && changeDate.isNotEmpty) 'change_date': changeDate,
      };

      try {
        final request = await _remoteDataSource.createRequest(body);
        createdRequests.add(request);
      } on DioException catch (e) {
        final msg = e.response?.data is Map && e.response?.data['message'] != null
            ? e.response!.data['message'].toString()
            : 'حدث خطأ في إرسال الطلب';
        errors.add(msg);
      } catch (e) {
        errors.add(e.toString());
      }
    }

    return BatchSubmitResult(createdRequests: createdRequests, errors: errors);
  }

  Future<List<LocationChangeRequestModel>> getRequests() async {
    return await _remoteDataSource.getRequests();
  }
}
