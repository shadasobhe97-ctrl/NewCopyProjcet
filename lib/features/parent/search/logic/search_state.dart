import '../data/models/driver_search_model.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<DriverSearchModel> drivers;
  SearchLoaded(this.drivers);
}

class SearchError extends SearchState {
  final String errorMessage;
  SearchError(this.errorMessage);
}

class SubscriptionLoading extends SearchState {}

class SubscriptionSuccess extends SearchState {
  final String message;
  SubscriptionSuccess(this.message);
}

class SubscriptionError extends SearchState {
  final String errorMessage;
  SubscriptionError(this.errorMessage);
}
