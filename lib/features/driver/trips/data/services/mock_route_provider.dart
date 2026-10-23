import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_stop_model.dart';
import 'package:kids_transport/features/driver/trips/data/models/live_trip_child_item.dart';

/// حالات محاكي الرحلة الذكي الثلاث
enum SmartTripPhase {
  beforePickup, // الحالة 1: قبل صعود أي طفل (32.884500, 13.184500)
  duringPickup, // الحالة 2: أثناء تجميع الأطفال (32.876500, 13.176500)
  headingToSchool, // الحالة 3: التوجه إلى المدارس (32.890000, 13.190000)
}

/// تقييم وتحديد مرحلة المحاكي الذكية بناءً على حالات الأطفال والمحطات الفعلية
SmartTripPhase? evaluateSmartTripPhase({
  required List<DriverTripStopModel> stops,
  required List<LiveTripChildItem> childItems,
}) {
  if (stops.isEmpty || childItems.isEmpty) return null;

  int boardedCount = 0;
  int pendingCount = 0;
  int absentOrSkippedCount = 0;
  int droppedCount = 0;

  for (final child in childItems) {
    final s = child.status;
    if (s == 'boarded') {
      boardedCount++;
    } else if (s == 'pending') {
      pendingCount++;
    } else if (s == 'dropped_off') {
      droppedCount++;
    } else if (s.startsWith('absent') || s.startsWith('skipped')) {
      absentOrSkippedCount++;
    }
  }

  // تمييز محطات الاستلام والإنزال
  final homeStops = stops.where((s) => s.isHome && !s.isBreakdownTransfer).toList();
  final schoolStops = stops.where((s) => s.isSchool && !s.isBreakdownTransfer).toList();

  final hasHomeStops = homeStops.isNotEmpty;
  final pickupStops = hasHomeStops ? homeStops : schoolStops;
  final dropoffStops = hasHomeStops ? schoolStops : homeStops;

  final allPickupUnresolved = pickupStops.isNotEmpty && pickupStops.every((s) => !s.isResolved);

  // 1. الحالة الأولى: قبل صعود أي طفل
  // - لا تتحدد إذا كان بعض الأطفال absent أو skipped، أو إذا كانت البيانات لم تُحمّل.
  // - الجميع pending، لا يوجد boarded، لا يوجد absent/skipped، وكافة محطات الاستلام غير مكتملة.
  if (boardedCount == 0 &&
      absentOrSkippedCount == 0 &&
      droppedCount == 0 &&
      pendingCount == childItems.length &&
      allPickupUnresolved) {
    return SmartTripPhase.beforePickup;
  }

  // 2. الحالة الثالثة: التوجه إلى المدارس
  // - اكتمال استلام الأطفال (pendingCount == 0).
  // - صعد طفل واحد على الأقل على متن الحافلة (boardedCount >= 1).
  // - توجد محطات إنزال/مدارس غير مكتملة لم يُنزل الطلاب عندها بعد.
  final hasUnresolvedDropoffs = dropoffStops.any((s) => !s.isResolved);
  if (pendingCount == 0 && boardedCount >= 1 && hasUnresolvedDropoffs) {
    return SmartTripPhase.headingToSchool;
  }

  // 3. الحالة الثانية: أثناء تجميع الأطفال
  // - صعد طفل واحد أو أكثر (boardedCount >= 1) وما زال هناك أطفال بحالة pending لم يصعدوا بعد.
  if (boardedCount >= 1 && pendingCount > 0) {
    return SmartTripPhase.duringPickup;
  }

  return null;
}

/// نقطة واحدة من ملف مسار المحاكاة
class MockRoutePoint {
  final double latitude;
  final double longitude;

  /// السرعة بالملف بوحدة كم/ساعة
  final double speedKmh;
  final double heading;
  final bool isStop;
  final String currentLeg;
  final String? stopName;

  const MockRoutePoint({
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.heading,
    required this.isStop,
    required this.currentLeg,
    this.stopName,
  });

  factory MockRoutePoint.fromJson(Map<String, dynamic> json) {
    final stopInfo = json['stop_info'];
    return MockRoutePoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      speedKmh: (json['speed'] as num?)?.toDouble() ?? 0,
      heading: (json['heading'] as num?)?.toDouble() ?? 0,
      isStop: json['is_stop'] == true,
      currentLeg: json['current_leg']?.toString() ?? '',
      stopName: stopInfo is Map ? stopInfo['stop_name']?.toString() : null,
    );
  }

  Position toPosition() => Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        accuracy: 5,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: heading,
        headingAccuracy: 0,
        // Geolocator يعطي السرعة بـ م/ث، فنحوّل من كم/ساعة لنفس الوحدة
        speed: speedKmh / 3.6,
        speedAccuracy: 0,
        isMocked: true,
      );
}

/// حالة المحاكاة لعرضها في لوحة الاختبار
class MockRouteStatus {
  final int step;
  final int total;
  final bool isRunning;
  final bool isWaitingAtStop;
  final bool isFinished;
  final String currentLeg;
  final String? stopName;

  const MockRouteStatus({
    this.step = 0,
    this.total = 0,
    this.isRunning = false,
    this.isWaitingAtStop = false,
    this.isFinished = false,
    this.currentLeg = '',
    this.stopName,
  });
}

/// يقرأ مسار رحلة وهمي من ملف JSON ويبث نقطة كل [tickInterval] كأنه GPS.
/// عند أي نقطة is_stop يتوقف لين يُستدعى [continueFromStop].
/// للاختبار فقط — لا يُستخدم إلا عبر DriverLocationSource في وضع التطوير.
class MockRouteProvider {
  static const String assetPath = 'assets/mock_routes/morning_trip_5children_route.json';

  /// إحداثيات مراحل الاختبار الثلاث المحددة
  static const double phase1Lat = 32.884500;
  static const double phase1Lng = 13.184500;

  static const double phase2Lat = 32.876500;
  static const double phase2Lng = 13.176500;

  static const double phase3Lat = 32.890000;
  static const double phase3Lng = 13.190000;

  final Duration tickInterval;
  final ValueNotifier<MockRouteStatus> status = ValueNotifier(const MockRouteStatus());
  final StreamController<Position> _controller = StreamController<Position>.broadcast();

  List<MockRoutePoint> _points = const [];
  int _index = 0;
  bool _waitingAtStop = false;
  Timer? _timer;

  SmartTripPhase? _currentSmartPhase;
  SmartTripPhase? get currentSmartPhase => _currentSmartPhase;

  Position? _smartPosition;
  Position? get currentSmartPosition => _smartPosition;

  MockRouteProvider({this.tickInterval = const Duration(seconds: 2)});

  Stream<Position> get positions => _controller.stream;

  bool get isLoaded => _points.isNotEmpty || _smartPosition != null;

  Position? get currentPosition =>
      _smartPosition ?? (isLoaded && _points.isNotEmpty ? _points[_index].toPosition() : null);

  /// تحديث وتثبيت إحداثيات المحاكي بناءً على مرحلة الرحلة الذكية
  void updateSmartPhase(SmartTripPhase phase) {
    _currentSmartPhase = phase;
    final double lat;
    final double lng;
    final String label;

    switch (phase) {
      case SmartTripPhase.beforePickup:
        lat = phase1Lat;
        lng = phase1Lng;
        label = 'المرحلة 1: قبل صعود أي طفل (32.8845, 13.1845)';
        break;
      case SmartTripPhase.duringPickup:
        lat = phase2Lat;
        lng = phase2Lng;
        label = 'المرحلة 2: أثناء تجميع الأطفال (32.8765, 13.1765)';
        break;
      case SmartTripPhase.headingToSchool:
        lat = phase3Lat;
        lng = phase3Lng;
        label = 'المرحلة 3: التوجه إلى المدارس (32.8900, 13.1900)';
        break;
    }

    final pos = Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 10.0,
      speedAccuracy: 0.0,
      isMocked: true,
    );

    _smartPosition = pos;
    if (!_controller.isClosed) {
      _controller.add(pos);
    }

    status.value = MockRouteStatus(
      step: phase.index + 1,
      total: 3,
      isRunning: true,
      isWaitingAtStop: false,
      isFinished: false,
      currentLeg: label,
      stopName: label,
    );
  }

  Future<void> load() async {
    if (isLoaded) return;
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _points = (json['points'] as List)
        .map((p) => MockRoutePoint.fromJson(Map<String, dynamic>.from(p as Map)))
        .toList();
    _updateStatus();
  }

  /// توليد مسار محاكاة ديناميكي مبني مباشرة على محطات الرحلة الحقيقية [stops].
  /// إذا كانت هناك محطة طوارئ/حافلة معطلة، تأتي أولاً حتماً لاستلام الطلاب العالقين،
  /// ثم منازل الطلاب المتبقين، ثم المدارس.
  void loadFromStops(List<DriverTripStopModel> stops, {Position? startPosition}) {
    final validStops = stops.where((s) => s.latitude != 0.0 && s.longitude != 0.0).toList();
    if (validStops.isEmpty) return;

    // 1. محطة الطوارئ غير المنتهية (إن وُجدت) تأتي كأول وجهة إجبارياً
    final activeBreakdown = validStops.where((s) => s.isBreakdownTransfer && !s.isResolved).firstOrNull;

    // 2. محطات المنازل غير المكتملة
    final homeStops = validStops
        .where((s) => !s.isBreakdownTransfer && s.isHome && !s.isResolved)
        .toList();
    homeStops.sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));

    // 3. محطات المدارس غير المكتملة
    final schoolStops = validStops
        .where((s) => !s.isBreakdownTransfer && s.isSchool && !s.isResolved)
        .toList();
    schoolStops.sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));

    final orderedStops = <DriverTripStopModel>[
      ?activeBreakdown,
      ...homeStops,
      ...schoolStops,
    ];

    // في حال كانت كل المحطات مكتملة، نبقي المحطات بترتيبها المعتاد
    if (orderedStops.isEmpty) {
      orderedStops.addAll(validStops);
      orderedStops.sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));
    }

    final double startLat;
    final double startLng;
    final String startName;

    if (startPosition != null && startPosition.latitude != 0.0) {
      startLat = startPosition.latitude;
      startLng = startPosition.longitude;
      startName = 'موقع السائق الحالي';
    } else {
      startLat = orderedStops.first.latitude - 0.003;
      startLng = orderedStops.first.longitude - 0.003;
      startName = 'نقطة الانطلاق';
    }

    final generated = <MockRoutePoint>[];
    double prevLat = startLat;
    double prevLng = startLng;
    String prevName = startName;

    for (final stop in orderedStops) {
      final stopLabel = stop.isBreakdownTransfer
          ? (stop.label.isNotEmpty ? stop.label : 'محطة استلام الطلاب من الحافلة المتعطلة')
          : (stop.label.isNotEmpty
              ? stop.label
              : (stop.childName ?? stop.schoolName ?? 'محطة #${stop.sequenceOrder}'));

      final heading = _calculateHeading(prevLat, prevLng, stop.latitude, stop.longitude);
      const int stepsPerLeg = 10;

      for (int i = 1; i <= stepsPerLeg; i++) {
        final t = i / stepsPerLeg;
        final lat = prevLat + (stop.latitude - prevLat) * t;
        final lng = prevLng + (stop.longitude - prevLng) * t;
        final isStop = (i == stepsPerLeg);

        generated.add(
          MockRoutePoint(
            latitude: lat,
            longitude: lng,
            speedKmh: isStop ? 0.0 : 40.0,
            heading: heading,
            isStop: isStop,
            currentLeg: 'من [$prevName] إلى [$stopLabel]',
            stopName: isStop ? stopLabel : null,
          ),
        );
      }

      prevLat = stop.latitude;
      prevLng = stop.longitude;
      prevName = stopLabel;
    }

    _points = generated;
    _index = 0;
    _waitingAtStop = false;
    _updateStatus();
  }

  static double _calculateHeading(double lat1, double lon1, double lat2, double lon2) {
    final dLon = (lon2 - lon1) * (math.pi / 180.0);
    final y = math.sin(dLon) * math.cos(lat2 * (math.pi / 180.0));
    final x = math.cos(lat1 * (math.pi / 180.0)) * math.sin(lat2 * (math.pi / 180.0)) -
        math.sin(lat1 * (math.pi / 180.0)) * math.cos(lat2 * (math.pi / 180.0)) * math.cos(dLon);
    final brng = math.atan2(y, x) * (180.0 / math.pi);
    return (brng + 360.0) % 360.0;
  }

  void start() {
    if (!isLoaded || _timer != null || _waitingAtStop || _isAtEnd) return;
    _timer = Timer.periodic(tickInterval, (_) => _tick());
    _updateStatus();
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    _updateStatus();
  }

  void continueFromStop() {
    if (!_waitingAtStop) return;
    _waitingAtStop = false;
    start();
    _updateStatus();
  }

  void reset() {
    pause();
    _index = 0;
    _waitingAtStop = false;
    _smartPosition = null;
    _currentSmartPhase = null;
    _emitCurrent();
    _updateStatus();
  }

  bool get _isAtEnd => isLoaded && _index >= _points.length - 1;

  void _tick() {
    if (_isAtEnd) {
      pause();
      return;
    }
    _index++;
    _emitCurrent();
    // آخر نقطة = نهاية المسار، ما فيش بعدها شي نكمّل له
    if (_isAtEnd) {
      pause();
      return;
    }
    if (_points[_index].isStop) {
      _waitingAtStop = true;
      pause();
      return;
    }
    _updateStatus();
  }

  void _emitCurrent() {
    final position = currentPosition;
    if (position != null && !_controller.isClosed) _controller.add(position);
  }

  void _updateStatus() {
    if (_points.isEmpty) {
      status.value = const MockRouteStatus();
      return;
    }
    final point = _points[_index];
    status.value = MockRouteStatus(
      step: _index + 1,
      total: _points.length,
      isRunning: _timer != null,
      isWaitingAtStop: _waitingAtStop,
      isFinished: _isAtEnd,
      currentLeg: point.currentLeg,
      stopName: point.stopName,
    );
  }
}
