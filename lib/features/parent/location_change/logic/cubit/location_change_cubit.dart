import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/location_change_options_model.dart';
import '../../data/models/location_change_request_model.dart';
import '../../data/repositories/location_change_repository.dart';

abstract class LocationChangeState {}

class LocationChangeInitial extends LocationChangeState {}

class LocationChangeLoading extends LocationChangeState {}

class LocationChangeOptionsLoaded extends LocationChangeState {
  final LocationChangeOptionsModel options;
  final Set<int> selectedSubscriptionIds;
  final SavedAddressModel? selectedAddress;
  final double? customLat;
  final double? customLng;
  final String? customLabel;
  final String pointType; // 'pickup' or 'dropoff'
  final DateTime changeDate;
  final BatchPreviewResult? previewResult;
  final bool isPreviewLoading;
  final bool isSubmitting;
  final bool submitSuccess;
  final String? submitMessage;
  final String? error;

  LocationChangeOptionsLoaded({
    required this.options,
    required this.selectedSubscriptionIds,
    this.selectedAddress,
    this.customLat,
    this.customLng,
    this.customLabel,
    required this.pointType,
    required this.changeDate,
    this.previewResult,
    this.isPreviewLoading = false,
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.submitMessage,
    this.error,
  });

  LocationChangeOptionsLoaded copyWith({
    LocationChangeOptionsModel? options,
    Set<int>? selectedSubscriptionIds,
    SavedAddressModel? selectedAddress,
    bool clearSelectedAddress = false,
    double? customLat,
    double? customLng,
    String? customLabel,
    String? pointType,
    DateTime? changeDate,
    BatchPreviewResult? previewResult,
    bool clearPreview = false,
    bool? isPreviewLoading,
    bool? isSubmitting,
    bool? submitSuccess,
    String? submitMessage,
    String? error,
    bool clearError = false,
  }) {
    return LocationChangeOptionsLoaded(
      options: options ?? this.options,
      selectedSubscriptionIds: selectedSubscriptionIds ?? this.selectedSubscriptionIds,
      selectedAddress: clearSelectedAddress ? null : (selectedAddress ?? this.selectedAddress),
      customLat: customLat ?? this.customLat,
      customLng: customLng ?? this.customLng,
      customLabel: customLabel ?? this.customLabel,
      pointType: pointType ?? this.pointType,
      changeDate: changeDate ?? this.changeDate,
      previewResult: clearPreview ? null : (previewResult ?? this.previewResult),
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
  LocationChangeHistoryLoaded(this.requests);
}

class LocationChangeError extends LocationChangeState {
  final String message;
  LocationChangeError(this.message);
}

class LocationChangeCubit extends Cubit<LocationChangeState> {
  final LocationChangeRepository _repository;

  LocationChangeCubit(this._repository) : super(LocationChangeInitial());

  Future<void> fetchOptions() async {
    emit(LocationChangeLoading());
    try {
      final options = await _repository.getOptions();
      final allSubIds = options.activeSubscriptions.map((e) => e.activeSubscriptionId).toSet();
      final defaultAddress = options.addresses.isNotEmpty ? options.addresses.first : null;

      emit(LocationChangeOptionsLoaded(
        options: options,
        selectedSubscriptionIds: allSubIds,
        selectedAddress: defaultAddress,
        pointType: 'pickup',
        changeDate: DateTime.now(),
      ));
    } catch (e) {
      emit(LocationChangeError(e.toString()));
    }
  }

  void toggleSubscriptionSelection(int subscriptionId) {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return;

    final updated = Set<int>.from(currentState.selectedSubscriptionIds);
    if (updated.contains(subscriptionId)) {
      updated.remove(subscriptionId);
    } else {
      updated.add(subscriptionId);
    }

    emit(currentState.copyWith(
      selectedSubscriptionIds: updated,
      clearPreview: true,
    ));
  }

  void selectAllSubscriptions(bool selectAll) {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return;

    final updated = selectAll
        ? currentState.options.activeSubscriptions.map((e) => e.activeSubscriptionId).toSet()
        : <int>{};

    emit(currentState.copyWith(
      selectedSubscriptionIds: updated,
      clearPreview: true,
    ));
  }

  void selectAddress(SavedAddressModel address) {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return;

    emit(currentState.copyWith(
      selectedAddress: address,
      customLat: null,
      customLng: null,
      customLabel: null,
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

  void setPointType(String type) {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return;

    emit(currentState.copyWith(
      pointType: type,
      clearPreview: true,
    ));
  }

  void setChangeDate(DateTime date) {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return;

    emit(currentState.copyWith(
      changeDate: date,
      clearPreview: true,
    ));
  }

  Future<void> calculatePreview() async {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return;

    if (currentState.selectedSubscriptionIds.isEmpty) {
      emit(currentState.copyWith(error: 'يرجى اختيار رحلة واحدة على الأقل'));
      return;
    }

    if (currentState.selectedAddress == null && (currentState.customLat == null || currentState.customLng == null)) {
      emit(currentState.copyWith(error: 'يرجى اختيار عنوان الموقع الجديد'));
      return;
    }

    emit(currentState.copyWith(isPreviewLoading: true, clearError: true));

    try {
      final formattedDate = "${currentState.changeDate.year}-${currentState.changeDate.month.toString().padLeft(2, '0')}-${currentState.changeDate.day.toString().padLeft(2, '0')}";

      final previewResult = await _repository.previewBatch(
        activeSubscriptionIds: currentState.selectedSubscriptionIds.toList(),
        pointType: currentState.pointType,
        addressId: currentState.selectedAddress?.id,
        lat: currentState.customLat,
        lng: currentState.customLng,
        label: currentState.customLabel,
        changeDate: formattedDate,
      );

      emit(currentState.copyWith(
        isPreviewLoading: false,
        previewResult: previewResult,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isPreviewLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> submitRequests() async {
    final currentState = state;
    if (currentState is! LocationChangeOptionsLoaded) return;

    if (currentState.selectedSubscriptionIds.isEmpty) {
      emit(currentState.copyWith(error: 'يرجى اختيار رحلة واحدة على الأقل'));
      return;
    }

    emit(currentState.copyWith(isSubmitting: true, clearError: true));

    try {
      final formattedDate = "${currentState.changeDate.year}-${currentState.changeDate.month.toString().padLeft(2, '0')}-${currentState.changeDate.day.toString().padLeft(2, '0')}";

      final submitResult = await _repository.submitBatch(
        activeSubscriptionIds: currentState.selectedSubscriptionIds.toList(),
        pointType: currentState.pointType,
        addressId: currentState.selectedAddress?.id,
        lat: currentState.customLat,
        lng: currentState.customLng,
        label: currentState.customLabel,
        changeDate: formattedDate,
      );

      if (submitResult.createdRequests.isNotEmpty) {
        final count = submitResult.createdRequests.length;
        final msg = count == 1
            ? 'تم إرسال طلب تغيير الموقع لسائق الرحلة بانتظار موافقته'
            : 'تم إرسال $count طلبات تغيير الموقع للسائقين بانتظار موافقتهم';

        emit(currentState.copyWith(
          isSubmitting: false,
          submitSuccess: true,
          submitMessage: msg,
        ));
      } else {
        final errorMsg = submitResult.errors.isNotEmpty
            ? submitResult.errors.join('\n')
            : 'تعذر إرسال طلب تغيير الموقع';
        emit(currentState.copyWith(
          isSubmitting: false,
          error: errorMsg,
        ));
      }
    } catch (e) {
      emit(currentState.copyWith(
        isSubmitting: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> fetchHistory() async {
    emit(LocationChangeLoading());
    try {
      final requests = await _repository.getRequests();
      emit(LocationChangeHistoryLoaded(requests));
    } catch (e) {
      emit(LocationChangeError(e.toString()));
    }
  }
}
