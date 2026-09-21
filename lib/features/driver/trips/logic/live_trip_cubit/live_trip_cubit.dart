import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_details_model.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_live_model.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_stop_model.dart';
import 'package:kids_transport/features/driver/trips/data/models/live_trip_child_item.dart';
import 'package:kids_transport/features/driver/trips/data/models/trip_action_result_model.dart';
import 'package:kids_transport/features/driver/trips/data/models/vehicle_breakdown_model.dart';
import 'package:kids_transport/features/driver/trips/data/repositories/driver_trips_repository.dart';

part 'live_trip_state.dart';

/// كوبيت الرحلة الحية: الخريطة، المحطات، الطفل الحالي، التقدّم، والإجراءات
///
/// نقطة /stops تُرجع محطة مدرسة واحدة مشتركة بين عدة أطفال، بينما إجراءات
/// تحديث الحالة تحتاج trip_child_id فردياً لكل طفل من تفاصيل الرحلة. لذلك
/// هذا الكوبيت يدمج الاثنين في [LiveTripChildItem] واحد لكل طفل.
class LiveTripCubit extends Cubit<LiveTripState> {
  final DriverTripsRepository _repository;
  Timer? _locationTimer;
  Timer? _refreshTimer;

  LiveTripCubit(this._repository) : super(LiveTripInitial());

  Future<void> loadAll(int tripId) async {
    emit(LiveTripLoading());
    try {
      final results = await Future.wait([
        _repository.getTripLive(tripId),
        _repository.getStops(tripId),
        _repository.getTripDetails(tripId),
      ]);
      final live = results[0] as DriverTripLiveModel;
      final stopsResponse = results[1] as DriverTripStopsResponseModel;
      final details = results[2] as DriverTripDetailsModel;
      final sortedStops = _sortedBySequenceOrder(stopsResponse.stops);

      emit(
        LiveTripLoaded(
          tripStatus: stopsResponse.tripStatus,
          stops: stopsResponse.stops,
          childItems: _buildChildItems(details, sortedStops),
          currentChild: live.currentChild,
          progress: live.progress,
          routeName: details.routeName,
        ),
      );
    } catch (e) {
      emit(LiveTripError('فشل تحميل بيانات الرحلة: ${e.toString()}'));
    }
  }

  /// نسخة مُرتّبة من stops[] حسب sequence_order فقط — المصدر الرسمي الوحيد
  /// لترتيب المحطات بالرحلة الحية. لا تُستخدم لتعديل [LiveTripLoaded.stops]
  /// نفسها (تبقى بترتيبها الأصلي من الـ Backend لرسم الخريطة/الـ Polyline
  /// كما وصلت دون أي تعديل).
  List<DriverTripStopModel> _sortedBySequenceOrder(List<DriverTripStopModel> stops) {
    final sorted = List<DriverTripStopModel>.of(stops);
    sorted.sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));
    return sorted;
  }

  List<LiveTripChildItem> _buildChildItems(
    DriverTripDetailsModel details,
    List<DriverTripStopModel> sortedStops,
  ) {
    final schoolNameToId = <String, int>{};
    for (final school in details.schools) {
      schoolNameToId[school.name] = school.schoolId;
    }

    final homeStopByChildId = <int, DriverTripStopModel>{};
    final schoolStopBySchoolId = <int, DriverTripStopModel>{};
    for (final stop in sortedStops) {
      if (stop.isHome && stop.childId != null) {
        homeStopByChildId[stop.childId!] = stop;
      } else if (stop.isSchool && stop.schoolId != null) {
        schoolStopBySchoolId[stop.schoolId!] = stop;
      }
    }

    final items = details.children.map((child) {
      DriverTripStopModel? targetStop;
      if (child.status == 'pending') {
        targetStop = homeStopByChildId[child.childId];
      } else if (child.status == 'boarded') {
        final schoolId = schoolNameToId[child.school];
        targetStop = schoolId != null ? schoolStopBySchoolId[schoolId] : null;
      }

      double? targetLat = targetStop?.latitude;
      double? targetLng = targetStop?.longitude;
      bool targetIsSchool = targetStop?.isSchool ?? (child.status == 'boarded');

      if (child.status == 'pending') {
        targetLat ??= child.homeLocation?.lat;
        targetLng ??= child.homeLocation?.lng;
        targetIsSchool = false;
      } else if (child.status == 'boarded') {
        targetLat ??= child.schoolLocation?.lat;
        targetLng ??= child.schoolLocation?.lng;
        targetIsSchool = true;
      }

      return LiveTripChildItem(
        tripChildId: child.tripChildId,
        childId: child.childId,
        // Single Source of Truth لاسم الطفل: children[].name من /driver/trips/{id}
        name: child.name,
        photo: child.photo,
        school: child.school,
        pickupAddress: child.pickupAddress,
        dropoffAddress: child.dropoffAddress,
        status: child.status,
        sequenceOrder: child.sequenceOrder,
        // ترتيب المحطة الرسمي: stops[].sequence_order للمحطة المطابقة عبر
        // child_id/school_id فقط — هذا هو المُعتمد لترتيب القائمة أدناه،
        // وليس sequenceOrder أعلاه (يبقى للعرض فقط كرقم مرجعي بالبطاقة).
        stopSequenceOrder: targetStop?.sequenceOrder,
        eta: targetStop?.eta ?? child.eta,
        targetLatitude: targetLat,
        targetLongitude: targetLng,
        targetIsSchool: targetIsSchool,
      );
    }).toList();

    // الترتيب حصراً حسب stopSequenceOrder (من stops[].sequence_order).
    // أي عنصر بلا محطة مطابقة (بيانات Backend ناقصة) يُدفع لنهاية القائمة
    // دون اختراع رقم ترتيب له.
    items.sort((a, b) {
      final orderA = a.stopSequenceOrder;
      final orderB = b.stopSequenceOrder;
      if (orderA != null && orderB != null) return orderA.compareTo(orderB);
      if (orderA != null) return -1;
      if (orderB != null) return 1;
      return 0;
    });
    return items;
  }

  Future<void> _refreshSilently(int tripId) async {
    final current = state;
    if (current is! LiveTripLoaded) return;
    try {
      final results = await Future.wait([
        _repository.getTripLive(tripId),
        _repository.getStops(tripId),
        _repository.getTripDetails(tripId),
      ]);
      final live = results[0] as DriverTripLiveModel;
      final stopsResponse = results[1] as DriverTripStopsResponseModel;
      final details = results[2] as DriverTripDetailsModel;
      final sortedStops = _sortedBySequenceOrder(stopsResponse.stops);

      final latest = state;
      if (latest is! LiveTripLoaded) return;

      // إن كانت next_stop/next_child المخزّنة سابقاً أصبحت الآن هي نفسها
      // current_child الجديد (تطابق IDs)، فهذا تأكيد من الـ Backend أن
      // الرحلة تقدّمت فعلاً — نُفرغها بانتظار next_stop رسمية جديدة من
      // الإجراء التالي، بدل تركها مُعروضة خطأً كـ"تالية" وهي أصبحت حالية.
      final storedNextTripChildId = latest.nextChild?.tripChildId ?? latest.nextStop?.tripChildId;
      final nextBecameCurrent =
          storedNextTripChildId != null && storedNextTripChildId == live.currentChild?.tripChildId;

      emit(
        latest.copyWith(
          tripStatus: stopsResponse.tripStatus,
          stops: stopsResponse.stops,
          childItems: _buildChildItems(details, sortedStops),
          currentChild: live.currentChild,
          clearCurrentChild: live.currentChild == null,
          progress: live.progress,
          routeName: details.routeName,
          clearNextStop: nextBecameCurrent,
          clearNextChild: nextBecameCurrent,
        ),
      );
    } catch (_) {
      // فشل صامت للتحديث الدوري، لا نكسر واجهة السائق أثناء القيادة
    }
  }

  void startBackgroundSync(int tripId) {
    _locationTimer?.cancel();
    _refreshTimer?.cancel();
    _sendLocationPing(tripId);
    _locationTimer = Timer.periodic(
      const Duration(seconds: 12),
      (_) => _sendLocationPing(tripId),
    );
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) {
        // لا نسمح للتحديث الدوري بالكتابة فوق حالة إجراء لم يُؤكَّد بعد —
        // يمنع Race Condition/Flicker بين Action قيد التنفيذ والـ Refresh.
        // الإجراء نفسه ينادي _refreshSilently مباشرة بعد نجاحه، فلا تفويت
        // بأي تحديث فعلي.
        final current = state;
        if (current is LiveTripLoaded && current.pendingActionTripChildId != null) return;
        _refreshSilently(tripId);
      },
    );
  }

  Future<void> _sendLocationPing(int tripId) async {
    final current = state;
    if (current is! LiveTripLoaded || !current.isInProgress) return;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      await Future.wait([
        _repository.updateLocation(
          tripId,
          latitude: position.latitude,
          longitude: position.longitude,
          speed: position.speed,
        ),
        // 🌟 بث فوري لموقع السائق عبر Firebase Firestore لتتبع ولي الأمر اللحظي
        _repository.pushLiveTrackingToFirestore(
          tripId,
          latitude: position.latitude,
          longitude: position.longitude,
          heading: position.heading,
          speed: position.speed,
          status: current.tripStatus,
        ),
      ]);
    } catch (_) {
      // فشل صامت لتحديث الموقع الدوري، لا نكسر واجهة السائق أثناء القيادة
    }
  }

  String _optimisticStatusFor(LiveTripChildItem item, String action, {String? stage}) {
    switch (action) {
      case 'pickup':
        return 'boarded';
      case 'dropoff':
        return item.targetIsSchool ? 'dropped_off_school' : 'delivered_home';
      case 'absent':
        return 'absent_late';
      case 'skip':
        return 'skipped_unresponsive';
      case 'dropoff_failed':
        return 'dropoff_failed';
      case 'direct_parent_handling':
        return 'direct_parent_handling';
      default:
        if (stage == 'dropoff') {
          return item.targetIsSchool ? 'dropped_off_school' : 'delivered_home';
        }
        return 'boarded';
    }
  }

  Future<void> _applyOptimisticAction(
    int tripId,
    LiveTripChildItem item,
    String action, {
    String? stage,
    required Future<ChildStatusActionResultModel> Function() call,
  }) async {
    final current = state;
    if (current is! LiveTripLoaded) return;
    final previousItems = current.childItems;
    final optimisticItems = current.childItems
        .map((c) => c.tripChildId == item.tripChildId
            ? c.copyWith(status: _optimisticStatusFor(item, action, stage: stage))
            : c)
        .toList();

    emit(
      current.copyWith(
        childItems: optimisticItems,
        pendingActionTripChildId: item.tripChildId,
        clearActionError: true,
      ),
    );

    try {
      // نلتقط next_stop/next_child فعلياً من استجابة الـ Backend بدل تجاهلها
      final result = await call();
      final afterAction = state;
      if (afterAction is LiveTripLoaded) {
        emit(
          afterAction.copyWith(
            nextStop: result.nextStop,
            clearNextStop: result.nextStop == null,
            nextChild: result.nextChild,
            clearNextChild: result.nextChild == null,
          ),
        );
      }
      await _refreshSilently(tripId);
      final after = state;
      if (after is LiveTripLoaded) {
        emit(after.copyWith(clearPendingAction: true));
      }
    } catch (e) {
      final message = e is ApiException ? e.message : 'فشل تنفيذ العملية: ${e.toString()}';
      final latest = state;
      if (latest is LiveTripLoaded) {
        emit(
          latest.copyWith(
            childItems: previousItems,
            clearPendingAction: true,
            actionErrorMessage: message,
          ),
        );
      }
    }
  }

  Future<void> manualPickup(
    int tripId,
    LiveTripChildItem item, {
    required double latitude,
    required double longitude,
  }) {
    return _applyOptimisticAction(
      tripId,
      item,
      'pickup',
      call: () => _repository.updateChildStatus(
        tripId,
        item.tripChildId,
        action: 'pickup',
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  Future<void> manualDropoff(
    int tripId,
    LiveTripChildItem item, {
    required double latitude,
    required double longitude,
  }) {
    return _applyOptimisticAction(
      tripId,
      item,
      'dropoff',
      call: () => _repository.updateChildStatus(
        tripId,
        item.tripChildId,
        action: 'dropoff',
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  Future<void> markAbsent(
    int tripId,
    LiveTripChildItem item, {
    required double latitude,
    required double longitude,
  }) {
    return _applyOptimisticAction(
      tripId,
      item,
      'absent',
      call: () => _repository.updateChildStatus(
        tripId,
        item.tripChildId,
        action: 'absent',
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  Future<void> markDropoffFailed(
    int tripId,
    LiveTripChildItem item, {
    required double latitude,
    required double longitude,
  }) {
    return _applyOptimisticAction(
      tripId,
      item,
      'dropoff_failed',
      call: () => _repository.updateChildStatus(
        tripId,
        item.tripChildId,
        action: 'dropoff_failed',
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  Future<void> markDirectParentHandling(
    int tripId,
    LiveTripChildItem item, {
    required double latitude,
    required double longitude,
  }) {
    return _applyOptimisticAction(
      tripId,
      item,
      'direct_parent_handling',
      call: () => _repository.updateChildStatus(
        tripId,
        item.tripChildId,
        action: 'direct_parent_handling',
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  Future<void> skipChild(int tripId, LiveTripChildItem item) {
    return _applyOptimisticAction(
      tripId,
      item,
      'skip',
      call: () => _repository.skipChild(tripId, item.tripChildId),
    );
  }

  Future<void> scanQr(int tripId, LiveTripChildItem item, String qrCodeToken, {String? stage}) {
    return _applyOptimisticAction(
      tripId,
      item,
      'qr',
      stage: stage,
      call: () =>
          _repository.verifyQr(tripId, item.tripChildId, qrCodeToken: qrCodeToken, stage: stage),
    );
  }

  Future<void> completeTrip(int tripId) async {
    final current = state;
    if (current is! LiveTripLoaded) return;
    emit(current.copyWith(clearActionError: true, clearBlockingError: true));
    try {
      final summary = await _repository.completeTrip(tripId);
      unawaited(_repository.updateFirestoreTripStatus(tripId, 'completed'));
      emit(current.copyWith(tripStatus: 'completed', completedSummary: summary));
    } catch (e) {
      if (e is ApiException) {
        if (e.errorCode == 'FORGOTTEN_CHILDREN_ON_BUS') {
          emit(current.copyWith(blockingErrorCode: e.errorCode, blockingErrorMessage: e.message));
          return;
        }
        emit(current.copyWith(actionErrorMessage: e.message));
        return;
      }
      emit(current.copyWith(actionErrorMessage: 'فشل إنهاء الرحلة: ${e.toString()}'));
    }
  }

  Future<void> reportBreakdown(int tripId, VehicleBreakdownRequestModel request) async {
    final current = state;
    if (current is! LiveTripLoaded) return;
    try {
      final result = await _repository.reportBreakdown(tripId, request);
      unawaited(_repository.updateFirestoreTripStatus(tripId, 'suspended_breakdown'));
      emit(current.copyWith(
        tripStatus: 'suspended_breakdown',
        breakdownResult: result,
      ));
    } catch (e) {
      final message = e is ApiException ? e.message : 'فشل تسجيل توقف الرحلة: ${e.toString()}';
      emit(current.copyWith(actionErrorMessage: message));
    }
  }

  Future<void> resumeTrip(int tripId) async {
    final current = state;
    if (current is! LiveTripLoaded) return;
    try {
      final result = await _repository.resumeTrip(tripId);
      unawaited(_repository.updateFirestoreTripStatus(tripId, result.status));
      emit(current.copyWith(tripStatus: result.status));
    } catch (e) {
      final message = e is ApiException ? e.message : 'فشل استئناف الرحلة: ${e.toString()}';
      emit(current.copyWith(actionErrorMessage: message));
    }
  }

  void clearActionError() {
    final current = state;
    if (current is LiveTripLoaded) {
      emit(current.copyWith(clearActionError: true));
    }
  }

  void clearBlockingError() {
    final current = state;
    if (current is LiveTripLoaded) {
      emit(current.copyWith(clearBlockingError: true));
    }
  }

  @override
  Future<void> close() {
    _locationTimer?.cancel();
    _refreshTimer?.cancel();
    return super.close();
  }
}
