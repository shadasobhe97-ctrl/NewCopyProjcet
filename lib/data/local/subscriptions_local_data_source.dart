import 'package:kids_transport/core/services/hive_helper.dart';
import 'package:kids_transport/features/parent/subscriptions/data/models/active_subscription_model.dart';

abstract class SubscriptionsLocalDataSource {
  Future<List<ActiveSubscriptionModel>> getCachedSubscriptions();
  Future<void> cacheSubscriptions(List<ActiveSubscriptionModel> subscriptions);
  Future<void> removeSubscription(int id);
  Future<void> clearCache();
}

class SubscriptionsLocalDataSourceImpl implements SubscriptionsLocalDataSource {
  @override
  Future<List<ActiveSubscriptionModel>> getCachedSubscriptions() async {
    final box = HiveHelper.subscriptionsBox;
    final list = <ActiveSubscriptionModel>[];
    for (var key in box.keys) {
      final value = box.get(key);
      if (value is Map) {
        final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(value);
        list.add(ActiveSubscriptionModel.fromJson(jsonMap));
      }
    }
    return list;
  }

  @override
  Future<void> cacheSubscriptions(List<ActiveSubscriptionModel> subscriptions) async {
    final box = HiveHelper.subscriptionsBox;
    await box.clear();
    for (var sub in subscriptions) {
      await box.put(sub.id, sub.toJson());
    }
  }

  @override
  Future<void> removeSubscription(int id) async {
    final box = HiveHelper.subscriptionsBox;
    await box.delete(id);
  }

  @override
  Future<void> clearCache() async {
    final box = HiveHelper.subscriptionsBox;
    await box.clear();
  }
}
