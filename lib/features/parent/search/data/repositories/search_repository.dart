import 'package:flutter/material.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import '../datasources/search_remote_data_source.dart';
import '../models/driver_search_model.dart';
import '../models/subscription_request.dart';
import 'package:flutter/foundation.dart';

class SearchRepository {
  final SearchRemoteDataSource _dataSource;

  SearchRepository(this._dataSource);

  Future<(List<DriverSearchModel>?, String?)> searchDrivers(
    Map<String, dynamic> body,
  ) async {
    try {
      final list = await _dataSource.searchDrivers(body);
      return (list, null);
    } on ApiException catch (e) {
      return (null, e.message);
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error in searchDrivers: $e');
      debugPrint('Stack trace: $stackTrace');
      return (null, 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى.');
    }
  }

  Future<(bool, String)> sendSubscription(SubscriptionRequest request) async {
    try {
      final message = await _dataSource.sendSubscription(request);
      return (true, message);
    } on ApiException catch (e) {
      return (false, e.message);
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error in sendSubscription: $e');
      debugPrint('Stack trace: $stackTrace');
      return (false, 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى.');
    }
  }
}
