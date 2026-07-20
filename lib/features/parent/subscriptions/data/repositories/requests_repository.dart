import 'package:flutter/foundation.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import '../datasources/requests_remote_data_source.dart';
import '../models/request_model.dart';

class RequestsRepository {
  final RequestsRemoteDataSource _dataSource;

  RequestsRepository(this._dataSource);

  /// Returns (list, error, backendMessage)
  Future<(List<RequestModel>?, String?, String?)> getRequests({String? status}) async {
    debugPrint('RequestsRepository => getRequests(status: $status)');
    try {
      final (requests, message) = await _dataSource.getRequests(status: status);
      return (requests, null, message);
    } on ApiException catch (e) {
      return (null, e.message, null);
    } catch (e, st) {
      debugPrint('❌ RequestsRepository.getRequests error: $e\n$st');
      return (null, 'حدث خطأ غير متوقع: $e', null);
    }
  }

  /// Returns (request, error, backendMessage)
  Future<(RequestModel?, String?, String?)> getRequestDetail(int id) async {
    try {
      final (request, message) = await _dataSource.getRequestDetail(id);
      return (request, null, message);
    } on ApiException catch (e) {
      return (null, e.message, null);
    } catch (e) {
      return (null, 'حدث خطأ غير متوقع: $e', null);
    }
  }

  Future<(bool, String)> cancelRequest(int id, {String? reason}) async {
    try {
      final message = await _dataSource.cancelRequest(id, reason: reason);
      return (true, message);
    } on ApiException catch (e) {
      return (false, e.message);
    } catch (e) {
      return (false, 'حدث خطأ غير متوقع: $e');
    }
  }
}
