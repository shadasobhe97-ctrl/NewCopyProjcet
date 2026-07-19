import '../../data/models/request_model.dart';

abstract class RequestsState {
  const RequestsState();
}

class RequestsInitial extends RequestsState {}

class RequestsLoading extends RequestsState {}

class RequestsLoaded extends RequestsState {
  final List<RequestModel> requests;
  const RequestsLoaded(this.requests);
}

class RequestsEmpty extends RequestsState {}

class RequestsError extends RequestsState {
  final String message;
  const RequestsError(this.message);
}

class RequestDetailLoading extends RequestsState {}

class RequestDetailLoaded extends RequestsState {
  final RequestModel request;
  const RequestDetailLoaded(this.request);
}

class RequestDetailError extends RequestsState {
  final String message;
  const RequestDetailError(this.message);
}

class RequestsActionLoading extends RequestsState {
  final List<RequestModel> currentList;
  final int actionId;
  const RequestsActionLoading(this.currentList, this.actionId);
}

class RequestsActionSuccess extends RequestsState {
  final List<RequestModel> updatedList;
  final String message;
  const RequestsActionSuccess(this.updatedList, this.message);
}

class RequestsActionError extends RequestsState {
  final List<RequestModel> currentList;
  final String message;
  const RequestsActionError(this.currentList, this.message);
}

