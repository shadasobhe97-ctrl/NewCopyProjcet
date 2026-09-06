import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/search_repository.dart';
import '../data/models/driver_search_model.dart';
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

    final Map<String, dynamic> queryParams = {};
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      queryParams['search'] = searchQuery.trim();
    }
    if (driverGender != null &&
        driverGender.trim().isNotEmpty &&
        driverGender.toUpperCase() != 'ALL') {
      queryParams['gender'] = driverGender.toLowerCase();
    }
    if (hasAc == true) {
      queryParams['has_ac'] = 1;
    }
    if (childIds != null && childIds.isNotEmpty) {
      queryParams['child_ids[]'] = childIds;
    }

    final (list, error) = await _repository.searchDrivers(queryParams);

    if (error != null) {
      emit(SearchError(error));
    } else {
      emit(SearchLoaded(list ?? []));
    }
  }

  Future<void> getPricing({
    required String searchQuery,
    required List<int> childIds,
  }) async {
    emit(PricingLoading());

    final queryParams = <String, dynamic>{
      if (searchQuery.trim().isNotEmpty) 'search': searchQuery.trim(),
      if (childIds.isNotEmpty) 'child_ids[]': childIds,
    };

    final (list, error) = await _repository.searchDrivers(queryParams);

    if (error != null) {
      emit(PricingError(error));
    } else if (list != null && list.isNotEmpty) {
      emit(PricingLoaded(list.first));
    } else {
      emit(PricingError('لم يتم العثور على السائق.'));
    }
  }

  /// يعيد جلب تسعير سائق محدد بناءً على المجموعة الحالية من الأطفال المختارين
  /// (لا يعتمد على أي بيانات مخزّنة سابقاً)، حتى يعكس خصم الإخوة الصحيح
  /// عندما يغيّر ولي الأمر عدد/هوية الأطفال بعد نتيجة البحث الأولى.
  Future<DriverSearchModel?> fetchDriverPricing({
    required int driverId,
    required List<int> childIds,
  }) async {
    if (childIds.isEmpty) return null;

    final (list, error) =
        await _repository.searchDrivers({'child_ids[]': childIds});

    if (error != null || list == null || list.isEmpty) return null;

    try {
      return list.firstWhere((d) => d.driverId == driverId);
    } catch (_) {
      return list.first;
    }
  }

  Future<void> submitSubscription(SubscriptionRequest request) async {
    debugPrint('\n>>> [SearchCubit] submitSubscription called');
    debugPrint('>>> Request JSON: ${request.toJson()}');
    emit(SubscriptionLoading());

    final (success, message) = await _repository.sendSubscription(request);

    debugPrint('>>> [SearchCubit] Result — success: $success, message: $message');

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
