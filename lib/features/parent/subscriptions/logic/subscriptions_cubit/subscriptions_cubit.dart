import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/subscriptions_repository.dart';
import '../../data/models/subscription_model.dart';
import 'subscriptions_state.dart';

export 'subscriptions_state.dart';

class SubscriptionsCubit extends Cubit<SubscriptionsState> {
  final SubscriptionsRepository _repository;

  SubscriptionsCubit(this._repository) : super(SubscriptionsInitial());

  Future<void> fetchSubscriptions() async {
    emit(SubscriptionsLoading());
    final (subscriptions, error) = await _repository.getMySubscriptions();
    if (error != null) {
      emit(SubscriptionsError(error));
    } else {
      emit(SubscriptionsLoaded(subscriptions ?? []));
    }
  }

  Future<void> cancelSubscription(int id) async {
    final currentList = state is SubscriptionsLoaded
        ? (state as SubscriptionsLoaded).subscriptions
        : <SubscriptionModel>[];

    emit(SubscriptionsActionLoading(List.from(currentList), id));

    final (success, message) = await _repository.cancelSubscriptionRequest(id);
    if (success) {
      final updatedList = List<SubscriptionModel>.from(currentList)
        ..removeWhere((sub) => sub.id == id);
      emit(SubscriptionsActionSuccess(updatedList, message));
    } else {
      emit(SubscriptionsActionError(List.from(currentList), message));
    }
  }
}
