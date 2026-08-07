import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import '../../data/repositories/trips_repository.dart';
import 'trip_history_state.dart';

class TripHistoryCubit extends Cubit<TripHistoryState> {
  final TripsRepository _repository;
  bool _isLoadingMore = false;

  TripHistoryCubit(this._repository) : super(TripHistoryInitial());

  Future<void> loadHistory() async {
    emit(TripHistoryLoading());
    try {
      final response = await _repository.getTripHistory(page: 1, perPage: 15);
      emit(TripHistoryLoaded(
        historyTrips: response.data,
        currentPage: response.currentPage,
        perPage: response.perPage,
        total: response.total,
        hasMore: response.hasMore,
      ));
    } catch (e) {
      final msg = (e is ApiException)
          ? e.message
          : e.toString().replaceAll('Exception:', '').trim();
      emit(TripHistoryError(msg));
    }
  }

  void filterByChild(int? childId) {
    if (state is TripHistoryLoaded) {
      final current = state as TripHistoryLoaded;
      emit(current.copyWith(selectedChildId: childId));
    }
  }

  void filterByDate(String? date) {
    if (state is TripHistoryLoaded) {
      final current = state as TripHistoryLoaded;
      emit(current.copyWith(selectedDate: date));
    }
  }

  void filterByDirection(String direction) {
    if (state is TripHistoryLoaded) {
      final current = state as TripHistoryLoaded;
      emit(current.copyWith(selectedDirection: direction));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! TripHistoryLoaded || _isLoadingMore || !currentState.hasMore) {
      return;
    }

    _isLoadingMore = true;
    final nextPage = currentState.currentPage + 1;

    try {
      final response = await _repository.getTripHistory(
        page: nextPage,
        perPage: currentState.perPage,
      );
      emit(currentState.copyWith(
        historyTrips: [...currentState.historyTrips, ...response.data],
        currentPage: response.currentPage,
        total: response.total,
        hasMore: response.hasMore,
      ));
    } catch (e) {
      // Keep state on pagination error
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    await loadHistory();
  }
}
