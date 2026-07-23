import 'package:kids_transport/features/driver/requests/data/datasources/driver_requests_remote_data_source.dart';
import 'package:kids_transport/features/driver/requests/data/models/driver_request_model.dart';

/// مستودع طلبات السائق
class DriverRequestsRepository {
  final DriverRequestsRemoteDataSource _remoteDataSource;

  DriverRequestsRepository(this._remoteDataSource);

  Future<PaginatedDriverRequests> getRequests({String? filter, int page = 1}) =>
      _remoteDataSource.fetchRequests(filter: filter, page: page);

  Future<DriverRequestModel> getRequestDetails(int requestId) =>
      _remoteDataSource.fetchRequestDetails(requestId);

  Future<void> acceptRequest(int requestId) =>
      _remoteDataSource.acceptRequest(requestId);

  Future<void> rejectRequest(int requestId, {required String reason}) =>
      _remoteDataSource.rejectRequest(requestId, reason: reason);
}
