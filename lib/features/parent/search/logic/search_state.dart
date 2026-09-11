import '../data/models/driver_search_model.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<DriverSearchModel> drivers;
  final SearchContextModel? searchContext;
  SearchLoaded(this.drivers, {this.searchContext});
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

class PricingLoading extends SearchState {}

class PricingLoaded extends SearchState {
  final DriverSearchModel driver;
  final SearchContextModel? searchContext;
  PricingLoaded(this.driver, {this.searchContext});
}

class PricingError extends SearchState {
  final String errorMessage;
  PricingError(this.errorMessage);
}
