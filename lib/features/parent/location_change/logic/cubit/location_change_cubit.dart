import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/features/parent/addresses/data/models/address_model.dart';
import 'package:kids_transport/features/parent/addresses/data/repositories/address_repository.dart';
import '../../data/models/location_change_available_trips_model.dart';
import '../../data/models/location_change_options_model.dart';
import '../../data/models/location_change_preview_model.dart';
import '../../data/models/location_change_request_model.dart';
import '../../data/repositories/location_change_repository.dart';

abstract class LocationChangeState {}

class LocationChangeInitial extends LocationChangeState {}

class LocationChangeLoading extends LocationChangeState {}

class LocationChangeOptionsLoaded extends LocationChangeState {
  final LocationChangeOptionsModel options;
  final Set<int> selectedChildIds;
  final List<ChildAvailableTripsModel> availableTrips;
  final Map<int, Set<int>> selectedTripIdsForChild; // child_id -> set of trip_ids
  final SavedAddressModel? selectedAddress;
  final double? customLat;
  final double? customLng;
  final String? customLabel;
  final String pointType; // 'pickup' or 'dropoff'
  final DateTime changeDate;
  final int currentStep; // 1: Children & Date, 2: Trips & Location, 3: Preview
  final LocationChangePreviewModel? previewData;
  final bool isAvailableTripsLoading;
  final bool isPreviewLoading;
  final bool isSubmitting;
  final bool submitSuccess;
  final String? submitMessage;
  final String? error;

  LocationChangeOptionsLoaded({
    required this.options,
    required this.selectedChildIds,
    this.availableTrips = const [],
    this.selectedTripIdsForChild = const {},
    this.selectedAddress,
    this.customLat,
    this.customLng,
    this.customLabel,
    required this.pointType,
    required this.changeDate,
    this.currentStep = 1,
    this.previewData,
    this.isAvailableTripsLoading = false,
    this.isPreviewLoading = false,
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.submitMessage,
    this.error,
  });

  LocationChangeOptionsLoaded copyWith({
    LocationChangeOptionsModel? options,
    Set<int>? selectedChildIds,
    List<ChildAvailableTripsModel>? availableTrips,
    Map<int, Set<int>>? selectedTripIdsForChild,
    SavedAddressModel? selectedAddress,
    bool clearSelectedAddress = false,
    double? customLat,
    double? customLng,
    String? customLabel,
    bool clearCustomLocation = false,
    String? pointType,
    DateTime? changeDate,
    int? currentStep,
    LocationChangePreviewModel? previewData,
    bool clearPreview = false,
    bool? isAvailableTripsLoading,
    bool? isPreviewLoading,
    bool? isSubmitting,
    bool? submitSuccess,
    String? submitMessage,
    String? error,
    bool clearError = false,
  }) {
    return LocationChangeOptionsLoaded(
      options: options ?? this.options,
      selectedChildIds: selectedChildIds ?? this.selectedChildIds,
      availableTrips: availableTrips ?? this.availableTrips,
      selectedTripIdsForChild: selectedTripIdsForChild ?? this.selectedTripIdsForChild,
      selectedAddress: clearSelectedAddress ? null : (selectedAddress ?? this.selectedAddress),
      customLat: clearCustomLocation ? null : (customLat ?? this.customLat),
      customLng: clearCustomLocation ? null : (customLng ?? this.customLng),
      customLabel: clearCustomLocation ? null : (customLabel ?? this.customLabel),
      pointType: pointType ?? this.pointType,
      changeDate: changeDate ?? this.changeDate,
      currentStep: currentStep ?? this.currentStep,
      previewData: clearPreview ? null : (previewData ?? this.previewData),
      isAvailableTripsLoading: isAvailableTripsLoading ?? this.isAvailableTripsLoading,
      isPreviewLoading: isPreviewLoading ?? this.isPreviewLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      submitMessage: submitMessage ?? this.submitMessage,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class LocationChangeHistoryLoaded extends LocationChangeState {
  final List<LocationChangeRequestModel> requests;
  final String currentStatusFilter;
  final bool isCancelling;
  final String? actionMessage;

  LocationChangeHistoryLoaded(
    this.requests, {
    this.currentStatusFilter = 'all',
    this.isCancelling = false,
    this.actionMessage,
  });
}

class LocationChangeError extends LocationChangeState {
  final String message;
  LocationChangeError(this.message);
}

class LocationChangeCubit extends Cubit<LocationChangeState> {
  final LocationChangeRepository _repository;

  LocationChangeCubit(this._repository) : super(LocationChangeInitial());

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  Future<void> fetchOptions() async {
    emit(LocationChangeLoading());
    try {
      final options = await _repository.getOptions();
      final defaultAddress = options.addresses.isNotEmpty ? options.addresses.first : null;
      
      // Auto-select children who have active subscriptions only
      final activeChildren = options.children.where((c) => c.hasActiveSubscription).toList();
      final initialChildIds = activeChildren.isNotEmpty ? {activeChildren.first.id} : <int>{};

      final initialLoaded = LocationChangeOptionsLoaded(
        options: options,
        selectedChildIds: initialChildIds,
        selectedAddress: defaultAddress,
        pointType: 'pickup',
        changeDate: DateTime.now(),
        currentStep: 1,
      );

      emit(initialLoaded);

      if (initialChildIds.isNotEmpty) {
        await _fetchAvailableTripsInternal(initialLoaded);
      }
    } catch (e) {
      emit(LocationChangeError(e.toString()));
    }
  }

  Map<int, Set<int>> _computeDefaultTrips(
    List<ChildAvailableTripsModel> availableTrips,
    Set<int> selectedChildIds,
    String pointType,
  ) {
    final result = <int, Set<int>>{};
    for (final childTrips in availableTrips) {
      if (!selectedChildIds.contains(childTrips.childId)) continue;
      final matching = childTrips.availableTrips.where((trip) {
        if (!trip.isEditable) return false;
        if (pointType == 'pickup') return trip.direction == 'to_school';
        if (pointType == 'dropoff') return trip.direction == 'to_home';
        return true;
      }).map((t) => t.activeSubscriptionId > 0 ? t.activeSubscriptionId : t.tripId).where((id) => id > 0).toSet();

      result[childTrips.childId] = matching;
    }
    return result;
  }

  Future<void> _fetchAvailableTripsInternal(LocationChangeOptionsLoaded currentState) async {
    if (currentState.selectedChildIds.isEmpty) {
      emit(currentState.copyWith(
        availableTrips: [],
        selectedTripIdsForChild: {},
        clearPreview: true,
      ));
      return;
    }

    emit(currentState.copyWith(isAvailableTripsLoading: true, clearError: true));

    try {
      final dateStr = _formatDate(currentState.changeDate);
      final trips = await _repository.getAvailableTrips(
        childIds: currentState.selectedChildIds.toList(),
        date: dateStr,
      );

      final defaultTripSelections = _computeDefaultTrips(
        trips,
        currentState.selectedChildIds,
        currentState.pointType,
      );

      emit(currentState.copyWith(
        isAvailableTripsLoading: false,
        availableTrips: trips,
        selectedTripIdsForChild: defaultTripSelections,
        clearPreview: true,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isAvailableTripsLoading: false,
        availableTrips: [],
        clearError: true,
      ));
    }
  }

  void clearError() {
    final currentState = state;
    if (currentState is LocationChangeOptionsLoaded) {
      emit(currentState.copyWith(clearError: true));
    }
  }

  void toggleChildSelection(int childId) {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return;

    final child = currentState.options.children.firstWhere(
      (c) => c.id == childId,
      orElse: () => ChildOptionModel(id: 0, name: ''),
    );

    if (!child.hasActiveSubscription) {
      emit(currentState.copyWith(
        error: 'الطفل "${child.name}" لا يملك اشتراكاً نشطاً لتعديل موقعه.',
      ));
      return;
    }

    final updated = Set<int>.from(currentState.selectedChildIds);
    if (updated.contains(childId)) {
      updated.remove(childId);
    } else {
      updated.add(childId);
    }

    final updatedState = currentState.copyWith(selectedChildIds: updated, clearPreview: true);
    emit(updatedState);
    _fetchAvailableTripsInternal(updatedState);
  }

  void selectAllChildren(bool selectAll) {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return;

    final updated = selectAll
        ? currentState.options.children
            .where((c) => c.hasActiveSubscription)
            .map((c) => c.id)
            .toSet()
        : <int>{};

    final updatedState = currentState.copyWith(selectedChildIds: updated, clearPreview: true);
    emit(updatedState);
    _fetchAvailableTripsInternal(updatedState);
  }

  void setChangeDate(DateTime date) {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return;

    final updatedState = currentState.copyWith(changeDate: date, clearPreview: true);
    emit(updatedState);
    _fetchAvailableTripsInternal(updatedState);
  }

  void setPointType(String type) {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return;

    final defaultTripSelections = _computeDefaultTrips(
      currentState.availableTrips,
      currentState.selectedChildIds,
      type,
    );

    emit(currentState.copyWith(
      pointType: type,
      selectedTripIdsForChild: defaultTripSelections,
      clearPreview: true,
    ));
  }

  void toggleTripSelectionForChild(int childId, int tripId) {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return;

    final map = Map<int, Set<int>>.from(
      currentState.selectedTripIdsForChild.map((k, v) => MapEntry(k, Set<int>.from(v))),
    );
    final trips = map[childId] ?? <int>{};

    if (trips.contains(tripId)) {
      trips.remove(tripId);
    } else {
      trips.add(tripId);
    }
    map[childId] = trips;

    emit(currentState.copyWith(
      selectedTripIdsForChild: map,
      clearPreview: true,
    ));
  }

  void selectAddress(SavedAddressModel address) {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return;

    emit(currentState.copyWith(
      selectedAddress: address,
      clearCustomLocation: true,
      clearPreview: true,
    ));
  }

  void setCustomLocation(double lat, double lng, String label) {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return;

    emit(currentState.copyWith(
      clearSelectedAddress: true,
      customLat: lat,
      customLng: lng,
      customLabel: label,
      clearPreview: true,
    ));
  }

  /// حفظ عنوان جديد في السيرفر وتحديث قائمة العناوين واختياره تلقائياً
  Future<String?> saveNewAddressAndSelect(AddressModel newAddress) async {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return 'الحالة غير جاهزة';

    try {
      final (success, message) = await getIt<AddressRepository>().addAddress(newAddress);
      if (!success) {
        return message;
      }

      // جلب أحدث قائمة عناوين بعد الإضافة
      final (latestAddresses, _) = await getIt<AddressRepository>().getAddresses();

      List<SavedAddressModel> updatedSavedAddresses = [];
      SavedAddressModel? newlyCreatedAddress;

      if (latestAddresses != null && latestAddresses.isNotEmpty) {
        updatedSavedAddresses = latestAddresses.map((a) => SavedAddressModel(
          id: int.tryParse(a.id ?? '') ?? 0,
          label: a.title,
          lat: a.latitude,
          lng: a.longitude,
        )).toList();

        // العنوان الجديد عادة هو الأخير أو يطابق الاسم والإحداثيات
        newlyCreatedAddress = updatedSavedAddresses.firstWhere(
          (a) => (a.label == newAddress.title) &&
                 (a.lat - newAddress.latitude).abs() < 0.001 &&
                 (a.lng - newAddress.longitude).abs() < 0.001,
          orElse: () => updatedSavedAddresses.last,
        );
      } else {
        newlyCreatedAddress = SavedAddressModel(
          id: int.tryParse(newAddress.id ?? '') ?? (DateTime.now().millisecondsSinceEpoch % 100000),
          label: newAddress.title,
          lat: newAddress.latitude,
          lng: newAddress.longitude,
        );
        updatedSavedAddresses = [newlyCreatedAddress, ...currentState.options.addresses];
      }

      final updatedOptions = LocationChangeOptionsModel(
        children: currentState.options.children,
        addresses: updatedSavedAddresses,
        activeSubscriptions: currentState.options.activeSubscriptions,
      );

      emit(currentState.copyWith(
        options: updatedOptions,
        selectedAddress: newlyCreatedAddress,
        clearCustomLocation: true,
        clearPreview: true,
      ));

      return null;
    } catch (e) {
      debugPrint('❌ [LocationChangeCubit] saveNewAddressAndSelect error: $e');
      return e.toString();
    }
  }

  void goToStep(int step) {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return;
    emit(currentState.copyWith(currentStep: step, clearError: true));
  }

  void backStep() {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return;
    if (currentState.currentStep > 1) {
      emit(currentState.copyWith(
        currentStep: currentState.currentStep - 1,
        clearError: true,
      ));
    }
  }

  Future<bool> proceedToStep2() async {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return false;

    if (currentState.selectedChildIds.isEmpty) {
      emit(currentState.copyWith(error: 'يرجى اختيار طفل واحد على الأقل للمتابعة'));
      return false;
    }

    if (currentState.availableTrips.isEmpty && !currentState.isAvailableTripsLoading) {
      await _fetchAvailableTripsInternal(currentState);
    }

    emit((state as LocationChangeOptionsLoaded).copyWith(currentStep: 2, clearError: true));
    return true;
  }

  Future<bool> proceedToStep3() async {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return false;

    if (currentState.selectedAddress == null &&
        (currentState.customLat == null || currentState.customLng == null)) {
      emit(currentState.copyWith(error: 'يرجى اختيار الموقع الجديد المطلوب للمتابعة'));
      return false;
    }

    final selections = _buildSelectionsPayload(currentState);
    if (selections.isEmpty) {
      emit(currentState.copyWith(error: 'لا توجد رحلات متاحة للأطفال المختارين في هذا التاريخ'));
      return false;
    }

    final hasEmptyTrips = selections.any((item) =>
        item['trip_ids'] == null || (item['trip_ids'] as List).isEmpty);
    if (hasEmptyTrips) {
      emit(currentState.copyWith(error: 'يرجى تحديد رحلة واحدة على الأقل لكل طفل تم اختياره'));
      return false;
    }

    await calculatePreview();

    final previewState = state;
    if (previewState is LocationChangeOptionsLoaded && previewState.previewData != null) {
      emit(previewState.copyWith(currentStep: 3, clearError: true));
      return true;
    }

    return false;
  }

  List<Map<String, dynamic>> _buildSelectionsPayload(LocationChangeOptionsLoaded currentState) {
    final selections = <Map<String, dynamic>>[];

    for (final childId in currentState.selectedChildIds) {
      final selectedTrips = currentState.selectedTripIdsForChild[childId];
      List<int> tripIds = [];

      if (selectedTrips != null && selectedTrips.isNotEmpty) {
        tripIds = selectedTrips.toList();
      } else {
        final childTrips = currentState.availableTrips.firstWhere(
          (t) => t.childId == childId,
          orElse: () => ChildAvailableTripsModel(childId: childId, childName: '', availableTrips: []),
        );

        final matchingTrips = childTrips.availableTrips.where((trip) {
          if (!trip.isEditable) return false;
          if (currentState.pointType == 'pickup') return trip.direction == 'to_school';
          if (currentState.pointType == 'dropoff') return trip.direction == 'to_home';
          return true;
        }).toList();

        tripIds = matchingTrips
            .map((t) => t.activeSubscriptionId > 0 ? t.activeSubscriptionId : t.tripId)
            .where((id) => id > 0)
            .toList();
      }

      selections.add({
        'child_id': childId,
        'trip_ids': tripIds,
      });
    }

    return selections;
  }

  Future<void> calculatePreview() async {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return;

    if (currentState.selectedChildIds.isEmpty) {
      emit(currentState.copyWith(error: 'يرجى اختيار طفل واحد على الأقل'));
      return;
    }

    if (currentState.selectedAddress == null &&
        (currentState.customLat == null || currentState.customLng == null)) {
      emit(currentState.copyWith(error: 'يرجى اختيار عنوان الموقع الجديد المطلوب'));
      return;
    }

    if (currentState.isAvailableTripsLoading) {
      emit(currentState.copyWith(error: 'جاري تحميل رحلات الأطفال، يرجى الانتظار'));
      return;
    }

    final selections = _buildSelectionsPayload(currentState);
    if (selections.isEmpty) {
      emit(currentState.copyWith(error: 'لا توجد رحلات للأطفال المختارين في هذا التاريخ'));
      return;
    }

    final isValid = selections.every((item) => item['trip_ids'] != null && (item['trip_ids'] as List).isNotEmpty);
    if (!isValid) {
      emit(currentState.copyWith(error: 'لا توجد رحلات قابلة للتعديل للوجهة المحددة للأطفال المختارين في هذا التاريخ'));
      return;
    }

    emit(currentState.copyWith(isPreviewLoading: true, clearError: true));

    final dateStr = _formatDate(currentState.changeDate);

    final (preview, error) = await _repository.previewRequest(
      pointType: currentState.pointType,
      date: dateStr,
      selections: selections,
      addressId: currentState.selectedAddress?.id,
      lat: currentState.selectedAddress != null ? null : currentState.customLat,
      lng: currentState.selectedAddress != null ? null : currentState.customLng,
      label: currentState.selectedAddress != null
          ? currentState.selectedAddress!.label
          : currentState.customLabel,
    );

    if (preview != null) {
      emit(currentState.copyWith(
        isPreviewLoading: false,
        previewData: preview,
      ));
    } else {
      emit(currentState.copyWith(
        isPreviewLoading: false,
        error: error ?? 'تعذر معاينة التكلفة',
      ));
    }
  }

  Future<void> submitRequests() async {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return;

    if (currentState.selectedChildIds.isEmpty) {
      emit(currentState.copyWith(error: 'يرجى اختيار طفل واحد على الأقل'));
      return;
    }

    if (currentState.isAvailableTripsLoading) {
      emit(currentState.copyWith(error: 'جاري تحميل رحلات الأطفال، يرجى الانتظار'));
      return;
    }

    final selections = _buildSelectionsPayload(currentState);
    if (selections.isEmpty) {
      emit(currentState.copyWith(error: 'لا توجد رحلات للأطفال المختارين في هذا التاريخ'));
      return;
    }

    final isValid = selections.every((item) => item['trip_ids'] != null && (item['trip_ids'] as List).isNotEmpty);
    if (!isValid) {
      emit(currentState.copyWith(error: 'لا توجد رحلات مطابقة للوجهة المحددة للأطفال المختارين في هذا التاريخ'));
      return;
    }

    emit(currentState.copyWith(isSubmitting: true, clearError: true));

    final dateStr = _formatDate(currentState.changeDate);

    final (createdRequests, error) = await _repository.createRequest(
      pointType: currentState.pointType,
      date: dateStr,
      selections: selections,
      addressId: currentState.selectedAddress?.id,
      lat: currentState.selectedAddress != null ? null : currentState.customLat,
      lng: currentState.selectedAddress != null ? null : currentState.customLng,
      label: currentState.selectedAddress != null
          ? currentState.selectedAddress!.label
          : currentState.customLabel,
    );

    if (createdRequests != null && createdRequests.isNotEmpty) {
      final count = createdRequests.length;
      final msg = count == 1
          ? 'تم إرسال طلب تغيير الموقع للسائق المعني بنجاح 🚀'
          : 'تم إرسال $count طلبات تغيير موقع للسائقين المعنيين بنجاح 🚀';

      emit(currentState.copyWith(
        isSubmitting: false,
        submitSuccess: true,
        submitMessage: msg,
      ));
    } else {
      emit(currentState.copyWith(
        isSubmitting: false,
        error: error ?? 'تعذر إرسال الطلب',
      ));
    }
  }

  Future<void> fetchHistory({String status = 'all'}) async {
    emit(LocationChangeLoading());
    try {
      final requests = await _repository.getRequests(status: status);
      emit(LocationChangeHistoryLoaded(requests, currentStatusFilter: status));
    } catch (e) {
      emit(LocationChangeError(e.toString()));
    }
  }

  Future<void> cancelRequest(int requestId) async {
    final currentState = state;
    if (currentState is! LocationChangeHistoryLoaded) return;

    emit(LocationChangeHistoryLoaded(
      currentState.requests,
      currentStatusFilter: currentState.currentStatusFilter,
      isCancelling: true,
    ));

    final (success, msg) = await _repository.cancelRequest(requestId);

    if (success) {
      final updatedRequests = await _repository.getRequests(status: currentState.currentStatusFilter);
      emit(LocationChangeHistoryLoaded(
        updatedRequests,
        currentStatusFilter: currentState.currentStatusFilter,
        isCancelling: false,
        actionMessage: msg ?? 'تم إلغاء الطلب بنجاح.',
      ));
    } else {
      emit(LocationChangeHistoryLoaded(
        currentState.requests,
        currentStatusFilter: currentState.currentStatusFilter,
        isCancelling: false,
        actionMessage: msg ?? 'تعذر إلغاء الطلب.',
      ));
    }
  }
}
