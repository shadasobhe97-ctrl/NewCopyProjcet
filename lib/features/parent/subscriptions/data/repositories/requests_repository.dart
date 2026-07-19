import 'package:flutter/foundation.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import '../datasources/requests_remote_data_source.dart';
import '../models/request_model.dart';

class RequestsRepository {
  final RequestsRemoteDataSource _dataSource;

  RequestsRepository(this._dataSource);

  Future<(List<RequestModel>?, String?)> getRequests({String? status}) async {
    debugPrint('RequestsRepository => getRequests(status: $status)');
    try {
      final requests = await _dataSource.getRequests(status: status);
      return (requests, null);
    } on ApiException catch (e) {
      return (null, e.message);
    } catch (e, st) {
      debugPrint('❌ RequestsRepository.getRequests error: $e\n$st');
      return (null, 'حدث خطأ غير متوقع: $e');
    }
  }

  Future<(RequestModel?, String?)> getRequestDetail(int id) async {
    try {
      final request = await _dataSource.getRequestDetail(id);
      return (request, null);
    } on ApiException catch (e) {
      return (null, e.message);
    } catch (e) {
      return (null, 'حدث خطأ غير متوقع: $e');
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
