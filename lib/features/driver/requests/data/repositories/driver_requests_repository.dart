import 'package:kids_transport/features/driver/requests/data/datasources/driver_requests_remote_data_source.dart';
import 'package:kids_transport/features/driver/requests/data/models/driver_request_model.dart';

/// مستودع طلبات السائق
class DriverRequestsRepository {
  final DriverRequestsRemoteDataSource _remoteDataSource;

  DriverRequestsRepository(this._remoteDataSource);

  Future<List<DriverRequestModel>> getRequests({String? filter}) =>
      _remoteDataSource.fetchRequests(filter: filter);

  Future<void> acceptRequest(int requestId) =>
      _remoteDataSource.acceptRequest(requestId);

  Future<void> rejectRequest(int requestId, {String? reason}) =>
      _remoteDataSource.rejectRequest(requestId, reason: reason);
}
