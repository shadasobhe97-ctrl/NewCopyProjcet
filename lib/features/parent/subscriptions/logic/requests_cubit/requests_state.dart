import '../../data/models/request_model.dart';

abstract class RequestsState {
  const RequestsState();
}

class RequestsInitial extends RequestsState {}

class RequestsLoading extends RequestsState {}

class RequestsLoaded extends RequestsState {
  final List<RequestModel> requests;
  final String? message;
  const RequestsLoaded(this.requests, {this.message});
}

class RequestsEmpty extends RequestsState {
  final String? message;
  const RequestsEmpty({this.message});
}

class RequestsError extends RequestsState {
  final String message;
  const RequestsError(this.message);
}

class RequestDetailLoading extends RequestsState {}

class RequestDetailLoaded extends RequestsState {
  final RequestModel request;
  final String? message;
  const RequestDetailLoaded(this.request, {this.message});
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
