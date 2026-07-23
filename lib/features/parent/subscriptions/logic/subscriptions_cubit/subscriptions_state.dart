import '../../data/models/active_subscription_model.dart';

abstract class SubscriptionsState {
  const SubscriptionsState();
}

class SubscriptionsInitial extends SubscriptionsState {}

class SubscriptionsLoading extends SubscriptionsState {}

class SubscriptionsLoaded extends SubscriptionsState {
  final List<ActiveSubscriptionModel> subscriptions;
  final String? message;
  const SubscriptionsLoaded(this.subscriptions, {this.message});
}

class SubscriptionsEmpty extends SubscriptionsState {
  final String? message;
  const SubscriptionsEmpty({this.message});
}

class SubscriptionsError extends SubscriptionsState {
  final String message;
  const SubscriptionsError(this.message);
}

class SubscriptionDetailLoading extends SubscriptionsState {}

class SubscriptionDetailLoaded extends SubscriptionsState {
  final ActiveSubscriptionModel detail;
  const SubscriptionDetailLoaded(this.detail);
}

class SubscriptionDetailError extends SubscriptionsState {
  final String message;
  const SubscriptionDetailError(this.message);
}

class SubscriptionsActionLoading extends SubscriptionsState {
  final List<ActiveSubscriptionModel> currentList;
  final int actionId;
  const SubscriptionsActionLoading(this.currentList, this.actionId);
}

class SubscriptionsActionSuccess extends SubscriptionsState {
  final List<ActiveSubscriptionModel> updatedList;
  final String message;
  const SubscriptionsActionSuccess(this.updatedList, this.message);
}

class SubscriptionsActionError extends SubscriptionsState {
  final List<ActiveSubscriptionModel> currentList;
  final String message;
  const SubscriptionsActionError(this.currentList, this.message);
}
