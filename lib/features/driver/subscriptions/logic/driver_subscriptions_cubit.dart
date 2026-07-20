import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/driver/subscriptions/data/models/driver_subscription_model.dart';
import 'package:kids_transport/features/driver/subscriptions/data/repositories/driver_subscriptions_repository.dart';

part 'driver_subscriptions_state.dart';

/// فلاتر الاشتراكات النشطة
enum DriverSubscriptionsFilter { all, currentActive, pendingStart, completed, cancelled }

/// كوبيت إدارة الاشتراكات النشطة للسائق
class DriverSubscriptionsCubit extends Cubit<DriverSubscriptionsState> {
  final DriverSubscriptionsRepository _repository;

  DriverSubscriptionsCubit(this._repository) : super(DriverSubscriptionsInitial());

  DriverSubscriptionsFilter _currentFilter = DriverSubscriptionsFilter.all;
  DriverSubscriptionsFilter get currentFilter => _currentFilter;

  /// تحميل الاشتراكات بالفلتر المناسب
  Future<void> loadSubscriptions({
    DriverSubscriptionsFilter filter = DriverSubscriptionsFilter.all,
  }) async {
    _currentFilter = filter;
    emit(DriverSubscriptionsLoading());

    try {
      final String? filterStr;
      switch (filter) {
        case DriverSubscriptionsFilter.currentActive:
          filterStr = 'current_active';
          break;
        case DriverSubscriptionsFilter.pendingStart:
          filterStr = 'pending_start';
          break;
        case DriverSubscriptionsFilter.completed:
          filterStr = 'completed';
          break;
        case DriverSubscriptionsFilter.cancelled:
          filterStr = 'cancelled';
          break;
        case DriverSubscriptionsFilter.all:
          filterStr = null;
          break;
      }

      final subscriptions = await _repository.getSubscriptions(filter: filterStr);
      emit(DriverSubscriptionsLoaded(subscriptions: subscriptions, activeFilter: filter));
    } catch (e) {
      emit(DriverSubscriptionsError('فشل تحميل الاشتراكات: ${e.toString()}'));
    }
  }

  /// إعادة تحميل الاشتراكات بنفس الفلتر الحالي
  Future<void> refresh() => loadSubscriptions(filter: _currentFilter);
}
