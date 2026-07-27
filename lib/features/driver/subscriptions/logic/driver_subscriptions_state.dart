part of 'driver_subscriptions_cubit.dart';

abstract class DriverSubscriptionsState {}

class DriverSubscriptionsInitial extends DriverSubscriptionsState {}

class DriverSubscriptionsLoading extends DriverSubscriptionsState {}

class DriverSubscriptionsLoaded extends DriverSubscriptionsState {
  final List<DriverSubscriptionModel> subscriptions;
  final DriverSubscriptionsFilter activeFilter;

  DriverSubscriptionsLoaded({
    required this.subscriptions,
    required this.activeFilter,
  });
}

class DriverSubscriptionsError extends DriverSubscriptionsState {
  final String message;

  DriverSubscriptionsError(this.message);
}

// ── شاشة التفاصيل ──
class DriverSubscriptionDetailLoading extends DriverSubscriptionsState {}

class DriverSubscriptionDetailLoaded extends DriverSubscriptionsState {
  final DriverSubscriptionModel subscription;

  DriverSubscriptionDetailLoaded(this.subscription);
}

class DriverSubscriptionDetailError extends DriverSubscriptionsState {
  final String message;

  DriverSubscriptionDetailError(this.message);
}
