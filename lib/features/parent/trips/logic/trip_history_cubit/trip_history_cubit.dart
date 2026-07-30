import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/trips_repository.dart';
import 'trip_history_state.dart';

class TripHistoryCubit extends Cubit<TripHistoryState> {
  final TripsRepository _repository;
  bool _isLoadingMore = false;

  TripHistoryCubit(this._repository) : super(TripHistoryInitial());

  Future<void> loadHistory() async {
    emit(TripHistoryLoading());
    try {
      final list = await _repository.getTripHistory(1);
      emit(TripHistoryLoaded(
        historyTrips: list,
        currentPage: 1,
        hasMore: list.isNotEmpty,
      ));
    } catch (e) {
      emit(TripHistoryError(e.toString()));
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
      final nextList = await _repository.getTripHistory(nextPage);
      if (nextList.isEmpty) {
        emit(currentState.copyWith(hasMore: false));
      } else {
        emit(currentState.copyWith(
          historyTrips: [...currentState.historyTrips, ...nextList],
          currentPage: nextPage,
          hasMore: true,
        ));
      }
    } catch (e) {
      // Keep state
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    await loadHistory();
  }
}
