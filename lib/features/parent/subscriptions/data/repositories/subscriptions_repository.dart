import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/data/local/subscriptions_local_data_source.dart';
import '../datasources/subscriptions_remote_data_source.dart';
import '../models/active_subscription_model.dart';

class SubscriptionsRepository {
  final SubscriptionsRemoteDataSource _remoteDataSource;
  final SubscriptionsLocalDataSource _localDataSource;

  SubscriptionsRepository(
    this._remoteDataSource,
    this._localDataSource,
  );

  // ---- قراءة الكاش فقط ----
  Future<List<ActiveSubscriptionModel>> getCachedSubscriptions() async {
    try {
      return await _localDataSource.getCachedSubscriptions();
    } catch (_) {
      return [];
    }
  }

  // ---- جلب قائمة الاشتراكات النشطة (API + تحديث الكاش) ----
  Future<(List<ActiveSubscriptionModel>?, String?, String?)> getMySubscriptions({
    String? filter,
  }) async {
    try {
      final (subscriptions, message) =
          await _remoteDataSource.getActiveSubscriptions(filter: filter);
      await _localDataSource.cacheSubscriptions(subscriptions);
      return (subscriptions, null, message);
    } on ApiException catch (e) {
      return (null, e.message, null);
    } catch (_) {
      return (null, 'حدث خطأ أثناء تحميل الاشتراكات، يرجى المحاولة مرة أخرى.', null);
    }
  }

  // ---- جلب تفاصيل طلب واحد ----
  Future<(ActiveSubscriptionModel?, String?)> getRequestDetail(int id) async {
    try {
      final detail = await _remoteDataSource.getSubscriptionDetail(id);
      return (detail, null);
    } on ApiException catch (e) {
      return (null, e.message);
    } catch (_) {
      return (null, 'تعذر تحميل تفاصيل الطلب، يرجى المحاولة مرة أخرى.');
    }
  }

  // ---- إلغاء الطلب (API First، ثم تحديث الكاش) ----
  Future<(bool, String)> cancelSubscriptionRequest(int id) async {
    try {
      final message = await _remoteDataSource.cancelSubscription(id);
      await _localDataSource.removeSubscription(id);
      return (true, message);
    } on ApiException catch (e) {
      return (false, e.message);
    } catch (_) {
      return (false, 'تعذر إلغاء الطلب، يرجى المحاولة مرة أخرى لاحقاً.');
    }
  }
}
