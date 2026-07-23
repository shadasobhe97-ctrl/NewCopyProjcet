part of 'driver_requests_cubit.dart';

abstract class DriverRequestsState {}

class DriverRequestsInitial extends DriverRequestsState {}

class DriverRequestsLoading extends DriverRequestsState {}

class DriverRequestsLoaded extends DriverRequestsState {
  final List<DriverRequestModel> requests;
  final DriverRequestsFilter activeFilter;
  final int currentPage;
  final int lastPage;
  final bool hasMore;
  final bool isLoadingMore;

  DriverRequestsLoaded({
    required this.requests,
    required this.activeFilter,
    required this.currentPage,
    required this.lastPage,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  DriverRequestsLoaded copyWith({
    List<DriverRequestModel>? requests,
    DriverRequestsFilter? activeFilter,
    int? currentPage,
    int? lastPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return DriverRequestsLoaded(
      requests: requests ?? this.requests,
      activeFilter: activeFilter ?? this.activeFilter,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class DriverRequestsError extends DriverRequestsState {
  final String message;
  DriverRequestsError(this.message);
}

// حالات تحميل طلب فردي
class DriverRequestDetailsLoading extends DriverRequestsState {}

class DriverRequestDetailsLoaded extends DriverRequestsState {
  final DriverRequestModel request;
  DriverRequestDetailsLoaded(this.request);
}

class DriverRequestDetailsError extends DriverRequestsState {
  final String message;
  DriverRequestDetailsError(this.message);
}
