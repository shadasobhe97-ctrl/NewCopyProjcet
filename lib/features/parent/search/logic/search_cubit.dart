import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/search_repository.dart';
import '../data/models/driver_search_model.dart';
import '../data/models/subscription_request.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository _repository;

  SearchContextModel? lastSearchContext;

  SearchCubit(this._repository) : super(SearchInitial());

  Future<void> searchDrivers({
    String? searchQuery,
    String? driverGender,
    bool? hasAc,
    List<int>? childIds,
    String? subscriptionType,
    String? tripDirection,
    String? startDate,
    String? endDate,
  }) async {
    emit(SearchLoading());

    final Map<String, dynamic> queryParams = {};

    if (childIds != null && childIds.isNotEmpty) {
      queryParams['child_ids[]'] = childIds;
    }

    if (subscriptionType != null && subscriptionType.trim().isNotEmpty) {
      queryParams['subscription_type'] = subscriptionType.trim();
    }

    if (tripDirection != null && tripDirection.trim().isNotEmpty) {
      queryParams['trip_direction'] = tripDirection.trim();
    }

    if (startDate != null && startDate.trim().isNotEmpty) {
      queryParams['start_date'] = startDate.trim();
    }

    if (endDate != null && endDate.trim().isNotEmpty) {
      queryParams['end_date'] = endDate.trim();
    }

    if (driverGender != null &&
        driverGender.trim().isNotEmpty &&
        driverGender.toUpperCase() != 'ALL') {
      queryParams['driver_gender'] = driverGender.toLowerCase();
    }

    if (hasAc != null) {
      queryParams['has_ac'] = hasAc;
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      queryParams['search_query'] = searchQuery.trim();
    }

    final (response, error) = await _repository.searchDrivers(queryParams);

    if (error != null) {
      emit(SearchError(error));
    } else if (response != null) {
      lastSearchContext = response.searchContext;
      emit(SearchLoaded(response.drivers, searchContext: response.searchContext));
    } else {
      emit(SearchLoaded([], searchContext: null));
    }
  }

  Future<void> getPricing({
    required String searchQuery,
    required List<int> childIds,
    int? driverId,
    String? subscriptionType,
    String? tripDirection,
    String? startDate,
    String? endDate,
  }) async {
    emit(PricingLoading());

    final queryParams = <String, dynamic>{
      if (searchQuery.trim().isNotEmpty) 'search_query': searchQuery.trim(),
      if (childIds.isNotEmpty) 'child_ids[]': childIds,
      if (subscriptionType != null && subscriptionType.isNotEmpty)
        'subscription_type': subscriptionType,
      if (tripDirection != null && tripDirection.isNotEmpty)
        'trip_direction': tripDirection,
      if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
      if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
    };

    final (response, error) = await _repository.searchDrivers(queryParams);

    if (error != null) {
      emit(PricingError(error));
    } else if (response != null && response.drivers.isNotEmpty) {
      lastSearchContext = response.searchContext;
      DriverSearchModel targetDriver;
      if (driverId != null) {
        try {
          targetDriver = response.drivers.firstWhere(
            (d) => d.driverId == driverId || d.driver.id == driverId,
          );
        } catch (_) {
          targetDriver = response.drivers.first;
        }
      } else {
        targetDriver = response.drivers.first;
      }
      emit(PricingLoaded(targetDriver,
          searchContext: response.searchContext));
    } else {
      emit(PricingError('لم يتم العثور على السائق.'));
    }
  }

  /// يعيد جلب تسعير سائق محدد بناءً على المجموعة الحالية من الأطفال وإعدادات الاشتراك
  Future<DriverSearchModel?> fetchDriverPricing({
    required int driverId,
    required List<int> childIds,
    String? searchQuery,
    String? subscriptionType,
    String? tripDirection,
    String? startDate,
    String? endDate,
  }) async {
    if (childIds.isEmpty) return null;

    final queryParams = <String, dynamic>{
      'child_ids[]': childIds,
      if (searchQuery != null && searchQuery.trim().isNotEmpty)
        'search_query': searchQuery.trim(),
      if (subscriptionType != null && subscriptionType.isNotEmpty)
        'subscription_type': subscriptionType,
      if (tripDirection != null && tripDirection.isNotEmpty)
        'trip_direction': tripDirection,
      if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
      if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
    };

    final (response, error) = await _repository.searchDrivers(queryParams);

    if (error != null || response == null || response.drivers.isEmpty) {
      return null;
    }

    if (response.searchContext != null) {
      lastSearchContext = response.searchContext;
    }

    try {
      return response.drivers.firstWhere(
        (d) => d.driverId == driverId || d.driver.id == driverId,
      );
    } catch (_) {
      return response.drivers.first;
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
