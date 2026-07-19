import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/data/local/subscriptions_local_data_source.dart';
import '../datasources/subscriptions_remote_data_source.dart';
import '../models/subscription_model.dart';

class SubscriptionsRepository {
  final SubscriptionsRemoteDataSource _remoteDataSource;
  final SubscriptionsLocalDataSource _localDataSource;

  SubscriptionsRepository(
    this._remoteDataSource,
    this._localDataSource,
  );

  // ---- قراءة الكاش فقط ----
  Future<List<SubscriptionModel>> getCachedSubscriptions() async {
    try {
      return await _localDataSource.getCachedSubscriptions();
    } catch (_) {
      return [];
    }
  }

  // ---- جلب قائمة الاشتراكات (API + تحديث الكاش) ----
  Future<(List<SubscriptionModel>?, String?)> getMySubscriptions(
      {String? status}) async {
    try {
      final subscriptions =
          await _remoteDataSource.getSubscriptions();
      await _localDataSource.cacheSubscriptions(subscriptions);
      return (subscriptions, null);
    } on ApiException catch (e) {
      return (null, e.message);
    } catch (_) {
      return (null, 'حدث خطأ أثناء تحميل الاشتراكات، يرجى المحاولة مرة أخرى.');
    }
  }

  // ---- جلب تفاصيل طلب واحد ----
  Future<(SubscriptionModel?, String?)> getRequestDetail(int id) async {
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
