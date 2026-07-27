import 'package:kids_transport/features/driver/subscriptions/data/datasources/driver_subscriptions_remote_data_source.dart';
import 'package:kids_transport/features/driver/subscriptions/data/models/driver_subscription_model.dart';

/// مستودع الاشتراكات النشطة للسائق
class DriverSubscriptionsRepository {
  final DriverSubscriptionsRemoteDataSource _remoteDataSource;

  DriverSubscriptionsRepository(this._remoteDataSource);

  Future<List<DriverSubscriptionModel>> getSubscriptions({String? filter}) {
    return _remoteDataSource.fetchSubscriptions(filter: filter);
  }

  Future<DriverSubscriptionModel> getSubscriptionDetail(int id) {
    return _remoteDataSource.fetchDetail(id);
  }
}
