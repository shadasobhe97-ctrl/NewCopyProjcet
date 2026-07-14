import '../../data/models/subscription_model.dart';

abstract class SubscriptionsState {}

class SubscriptionsInitial extends SubscriptionsState {}

class SubscriptionsLoading extends SubscriptionsState {}

class SubscriptionsLoaded extends SubscriptionsState {
  final List<SubscriptionModel> subscriptions;

  SubscriptionsLoaded(this.subscriptions);
}

class SubscriptionsActionLoading extends SubscriptionsLoaded {
  final int actionId;
  SubscriptionsActionLoading(super.subscriptions, this.actionId);
}

class SubscriptionsActionSuccess extends SubscriptionsLoaded {
  final String message;

  SubscriptionsActionSuccess(super.subscriptions, this.message);
}

class SubscriptionsActionError extends SubscriptionsLoaded {
  final String message;

  SubscriptionsActionError(super.subscriptions, this.message);
}

class SubscriptionsError extends SubscriptionsState {
  final String message;

  SubscriptionsError(this.message);
}
