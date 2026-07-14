import 'package:kids_transport/core/network/api_exception.dart';
import '../datasources/subscriptions_data_source.dart';
import '../models/subscription_model.dart';

class SubscriptionsRepository {
  final SubscriptionsDataSource _dataSource;

  SubscriptionsRepository(this._dataSource);

  Future<(List<SubscriptionModel>?, String?)> getMySubscriptions() async {
    try {
      final subscriptions = await _dataSource.getSubscriptions();
      return (subscriptions, null);
    } on ApiException catch (e) {
      return (null, e.message);
    } catch (_) {
      return (null, 'حدث خطأ أثناء تحميل الاشتراكات، يرجى المحاولة مرة أخرى.');
    }
  }

  Future<(bool, String)> cancelSubscriptionRequest(int id) async {
    try {
      await _dataSource.cancelSubscription(id);
      return (true, 'تم إلغاء طلب الاشتراك بنجاح.');
    } on ApiException catch (e) {
      return (false, e.message);
    } catch (_) {
      return (false, 'تعذر إلغاء الطلب، يرجى المحاولة مرة أخرى لاحقاً.');
    }
  }
}
