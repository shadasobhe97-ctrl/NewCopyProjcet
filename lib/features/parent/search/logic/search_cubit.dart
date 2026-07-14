import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/search_repository.dart';
import '../data/models/subscription_request.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository _repository;

  SearchCubit(this._repository) : super(SearchInitial());

  Future<void> searchDrivers({
    String? searchQuery,
    String? driverGender,
    bool? hasAc,
    List<int>? childIds,
  }) async {
    emit(SearchLoading());

    final Map<String, dynamic> body = {};
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      body['search_query'] = searchQuery.trim();
    }
    if (driverGender != null && driverGender != 'ALL') {
      body['driver_gender'] = driverGender.toLowerCase();
    }
    if (hasAc != null && hasAc) {
      body['has_ac'] = hasAc;
    }
    if (childIds != null && childIds.isNotEmpty) {
      body['child_ids'] = childIds;
    }

    final (list, error) = await _repository.searchDrivers(body);

    if (error != null) {
      emit(SearchError(error));
    } else {
      emit(SearchLoaded(list ?? []));
    }
  }

  Future<void> submitSubscription(SubscriptionRequest request) async {
    emit(SubscriptionLoading());

    final (success, message) = await _repository.sendSubscription(request);

    if (success) {
      emit(SubscriptionSuccess(message));
    } else {
      emit(SubscriptionError(message));
    }
  }

  void resetState() {
    emit(SearchInitial());
  }
}
