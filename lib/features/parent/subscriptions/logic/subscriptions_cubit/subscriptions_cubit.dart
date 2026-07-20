import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/subscriptions_repository.dart';
import '../../data/models/subscription_model.dart';
import 'subscriptions_state.dart';

export 'subscriptions_state.dart';

class SubscriptionsCubit extends Cubit<SubscriptionsState> {
  final SubscriptionsRepository _repository;

  SubscriptionsCubit(this._repository) : super(SubscriptionsInitial());

  /// جلب القائمة - Cache First مثل Children
  Future<void> fetchSubscriptions({String? status}) async {
    // 1. اقرأ Hive أولاً وعرض البيانات فوراً (نعرض الكاش فقط اذا مافي فلتر)
    if (status == null) {
      final cached = await _repository.getCachedSubscriptions();
      if (cached.isNotEmpty) {
        emit(SubscriptionsLoaded(cached));
      } else {
        emit(SubscriptionsLoading());
      }
    } else {
      emit(SubscriptionsLoading());
    }

    // 2. اطلب API في الخلفية
    final (subscriptions, error) =
        await _repository.getMySubscriptions(status: status);
    if (error != null) {
      if (status == null &&
          state is SubscriptionsLoaded &&
          (state as SubscriptionsLoaded).subscriptions.isNotEmpty) {
        emit(SubscriptionsLoaded((state as SubscriptionsLoaded).subscriptions));
      } else {
        emit(SubscriptionsError(error));
      }
    } else {
      final list = subscriptions ?? [];
      if (list.isEmpty) {
        emit(SubscriptionsEmpty());
      } else {
        emit(SubscriptionsLoaded(list));
      }
    }
  }

  /// جلب تفاصيل طلب واحد - GET /parent/requests/{id}
  Future<void> fetchSubscriptionDetail(int id) async {
    emit(SubscriptionDetailLoading());
    final (detail, error) = await _repository.getRequestDetail(id);
    if (error != null) {
      emit(SubscriptionDetailError(error));
    } else {
      emit(SubscriptionDetailLoaded(detail!));
    }
  }

  /// إلغاء الطلب - DELETE /parent/subscriptions/{id}
  Future<void> cancelSubscription(int id) async {
    final currentList = state is SubscriptionsLoaded
        ? (state as SubscriptionsLoaded).subscriptions
        : <SubscriptionModel>[];

    emit(SubscriptionsActionLoading(List.from(currentList), id));

    final (success, message) = await _repository.cancelSubscriptionRequest(id);
    if (success) {
      final updatedList = List<SubscriptionModel>.from(currentList)
        ..removeWhere((sub) => sub.id == id);
      if (updatedList.isEmpty) {
        emit(SubscriptionsActionSuccess([], message));
      } else {
        emit(SubscriptionsActionSuccess(updatedList, message));
      }
    } else {
      emit(SubscriptionsActionError(List.from(currentList), message));
    }
  }
}
