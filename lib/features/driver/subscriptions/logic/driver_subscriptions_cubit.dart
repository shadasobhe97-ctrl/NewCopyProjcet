import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/driver/subscriptions/data/models/driver_subscription_model.dart';
import 'package:kids_transport/features/driver/subscriptions/data/repositories/driver_subscriptions_repository.dart';

part 'driver_subscriptions_state.dart';

enum DriverSubscriptionsFilter { all, currentActive, pendingStart, completed, cancelled }

class DriverSubscriptionsCubit extends Cubit<DriverSubscriptionsState> {
  final DriverSubscriptionsRepository _repository;

  DriverSubscriptionsCubit(this._repository) : super(DriverSubscriptionsInitial());

  DriverSubscriptionsFilter _currentFilter = DriverSubscriptionsFilter.all;
  DriverSubscriptionsFilter get currentFilter => _currentFilter;

  Future<void> loadSubscriptions({
    DriverSubscriptionsFilter filter = DriverSubscriptionsFilter.all,
  }) async {
    _currentFilter = filter;
    emit(DriverSubscriptionsLoading());
    try {
      String? filterStr;
      switch (filter) {
        case DriverSubscriptionsFilter.currentActive:
          filterStr = 'active';
          break;
        case DriverSubscriptionsFilter.pendingStart:
          filterStr = 'pending';
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

  Future<void> loadSubscriptionDetail(int id) async {
    emit(DriverSubscriptionDetailLoading());
    try {
      final detail = await _repository.getSubscriptionDetail(id);
      emit(DriverSubscriptionDetailLoaded(detail));
    } catch (e) {
      emit(DriverSubscriptionDetailError('فشل تحميل تفاصيل الاشتراك: ${e.toString()}'));
    }
  }

  Future<void> refresh() => loadSubscriptions(filter: _currentFilter);
}
