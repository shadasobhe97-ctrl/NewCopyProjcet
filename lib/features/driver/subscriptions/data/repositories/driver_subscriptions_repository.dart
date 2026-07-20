import 'package:kids_transport/features/driver/subscriptions/data/datasources/driver_subscriptions_remote_data_source.dart';
import 'package:kids_transport/features/driver/subscriptions/data/models/driver_subscription_model.dart';

/// مستودع الاشتراكات النشطة للسائق
class DriverSubscriptionsRepository {
  final DriverSubscriptionsRemoteDataSource _remoteDataSource;

  DriverSubscriptionsRepository(this._remoteDataSource);

  Future<List<DriverSubscriptionModel>> getSubscriptions({String? filter}) {
    if (filter == 'current_active') {
      return _remoteDataSource.fetchCurrentActive();
    } else if (filter == 'pending_start') {
      return _remoteDataSource.fetchPendingStart();
    } else if (filter == 'completed') {
      return _remoteDataSource.fetchCompleted();
    } else if (filter == 'cancelled') {
      return _remoteDataSource.fetchCancelled();
    } else {
      return _remoteDataSource.fetchAll();
    }
  }
}
