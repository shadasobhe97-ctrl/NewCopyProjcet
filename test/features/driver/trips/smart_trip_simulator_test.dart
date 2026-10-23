import 'package:flutter_test/flutter_test.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_stop_model.dart';
import 'package:kids_transport/features/driver/trips/data/models/live_trip_child_item.dart';
import 'package:kids_transport/features/driver/trips/data/models/vehicle_breakdown_model.dart';
import 'package:kids_transport/features/driver/trips/data/services/mock_route_provider.dart';

void main() {
  group('Smart Trip Location & Breakdown Simulator Tests', () {
    final mockProvider = MockRouteProvider();

    DriverTripStopModel makeStop({
      required int id,
      required String type, // 'home' | 'school'
      required int seq,
      String status = 'pending',
      int? childId,
    }) {
      return DriverTripStopModel(
        id: id,
        stopType: type,
        sequenceOrder: seq,
        status: status,
        childId: childId,
        childName: childId != null ? 'طفل $childId' : null,
        schoolId: type == 'school' ? 10 : null,
        schoolName: type == 'school' ? 'مدرسة النور' : null,
        label: 'محطة $id',
        latitude: 32.880000,
        longitude: 13.180000,
        eta: null,
        etaMinutes: null,
      );
    }

    LiveTripChildItem makeChild({
      required int childId,
      required String status,
      int seq = 1,
    }) {
      return LiveTripChildItem(
        tripChildId: childId * 10,
        childId: childId,
        name: 'طالب $childId',
        school: 'مدرسة النور',
        pickupAddress: 'طرابلس',
        dropoffAddress: 'مدرسة النور',
        status: status,
        sequenceOrder: seq,
        eta: null,
        targetLatitude: 32.88,
        targetLongitude: 13.18,
        targetIsSchool: status == 'boarded',
      );
    }

    // ── الحالة 1 ──
    test('1. بدء الرحلة وجميع محطات استلام الأطفال غير مكتملة -> Phase 1 (beforePickup)', () {
      final stops = [
        makeStop(id: 1, type: 'home', seq: 1, childId: 1),
        makeStop(id: 2, type: 'home', seq: 2, childId: 2),
        makeStop(id: 3, type: 'school', seq: 3),
      ];
      final children = [
        makeChild(childId: 1, status: 'pending', seq: 1),
        makeChild(childId: 2, status: 'pending', seq: 2),
      ];

      final phase = evaluateSmartTripPhase(stops: stops, childItems: children);
      expect(phase, equals(SmartTripPhase.beforePickup));

      mockProvider.updateSmartPhase(phase!);
      expect(mockProvider.currentSmartPosition?.latitude, equals(32.884500));
      expect(mockProvider.currentSmartPosition?.longitude, equals(13.184500));
    });

    // ── الحالة 2 ──
    test('2. تأكيد صعود طفل واحد مع بقاء أطفال آخرين -> Phase 2 (duringPickup)', () {
      final stops = [
        makeStop(id: 1, type: 'home', seq: 1, status: 'completed', childId: 1),
        makeStop(id: 2, type: 'home', seq: 2, childId: 2),
        makeStop(id: 3, type: 'school', seq: 3),
      ];
      final children = [
        makeChild(childId: 1, status: 'boarded', seq: 1),
        makeChild(childId: 2, status: 'pending', seq: 2),
      ];

      final phase = evaluateSmartTripPhase(stops: stops, childItems: children);
      expect(phase, equals(SmartTripPhase.duringPickup));

      mockProvider.updateSmartPhase(phase!);
      expect(mockProvider.currentSmartPosition?.latitude, equals(32.876500));
      expect(mockProvider.currentSmartPosition?.longitude, equals(13.176500));
    });

    // ── الحالة 3 ──
    test('3. تأكيد صعود عدة أطفال مع بقاء محطات استلام أخرى -> Phase 2 (duringPickup)', () {
      final stops = [
        makeStop(id: 1, type: 'home', seq: 1, status: 'completed', childId: 1),
        makeStop(id: 2, type: 'home', seq: 2, status: 'completed', childId: 2),
        makeStop(id: 3, type: 'home', seq: 3, childId: 3),
        makeStop(id: 4, type: 'school', seq: 4),
      ];
      final children = [
        makeChild(childId: 1, status: 'boarded', seq: 1),
        makeChild(childId: 2, status: 'boarded', seq: 2),
        makeChild(childId: 3, status: 'pending', seq: 3),
      ];

      final phase = evaluateSmartTripPhase(stops: stops, childItems: children);
      expect(phase, equals(SmartTripPhase.duringPickup));

      mockProvider.updateSmartPhase(phase!);
      expect(mockProvider.currentSmartPosition?.latitude, equals(32.876500));
      expect(mockProvider.currentSmartPosition?.longitude, equals(13.176500));
    });

    // ── الحالة 4 ──
    test('4. اكتمال استلام الأطفال والتوجه إلى المدارس -> Phase 3 (headingToSchool)', () {
      final stops = [
        makeStop(id: 1, type: 'home', seq: 1, status: 'completed', childId: 1),
        makeStop(id: 2, type: 'home', seq: 2, status: 'completed', childId: 2),
        makeStop(id: 3, type: 'school', seq: 3, status: 'pending'),
      ];
      final children = [
        makeChild(childId: 1, status: 'boarded', seq: 1),
        makeChild(childId: 2, status: 'boarded', seq: 2),
      ];

      final phase = evaluateSmartTripPhase(stops: stops, childItems: children);
      expect(phase, equals(SmartTripPhase.headingToSchool));

      mockProvider.updateSmartPhase(phase!);
      expect(mockProvider.currentSmartPosition?.latitude, equals(32.890000));
      expect(mockProvider.currentSmartPosition?.longitude, equals(13.190000));
    });

    // ── الحالة 5 ──
    test('5. الإبلاغ عن عطل قبل صعود أي طفل -> إحداثيات البلاغ تطابق Phase 1', () {
      mockProvider.updateSmartPhase(SmartTripPhase.beforePickup);
      final activePos = mockProvider.currentPosition;
      expect(activePos, isNotNull);

      final req = VehicleBreakdownRequestModel(
        latitude: activePos?.latitude,
        longitude: activePos?.longitude,
        reason: 'عطل في المحرك قبل الصعود',
      );

      expect(req.latitude, equals(32.884500));
      expect(req.longitude, equals(13.184500));
      expect(req.toJson()['latitude'], equals(32.884500));
      expect(req.toJson()['longitude'], equals(13.184500));
    });

    // ── الحالة 6 ──
    test('6. الإبلاغ عن عطل بعد صعود بعض الأطفال -> إحداثيات البلاغ تطابق Phase 2', () {
      mockProvider.updateSmartPhase(SmartTripPhase.duringPickup);
      final activePos = mockProvider.currentPosition;
      expect(activePos, isNotNull);

      final req = VehicleBreakdownRequestModel(
        latitude: activePos?.latitude,
        longitude: activePos?.longitude,
        reason: 'عطل إطارات أثناء التجميع',
      );

      expect(req.latitude, equals(32.876500));
      expect(req.longitude, equals(13.176500));
      expect(req.toJson()['latitude'], equals(32.876500));
      expect(req.toJson()['longitude'], equals(13.176500));
    });

    // ── الحالة 7 ──
    test('7. الإبلاغ عن عطل بعد اكتمال صعود الأطفال وقبل اكتمال المدارس -> إحداثيات البلاغ تطابق Phase 3', () {
      mockProvider.updateSmartPhase(SmartTripPhase.headingToSchool);
      final activePos = mockProvider.currentPosition;
      expect(activePos, isNotNull);

      final req = VehicleBreakdownRequestModel(
        latitude: activePos?.latitude,
        longitude: activePos?.longitude,
        reason: 'ارتفاع حرارة المحرك في الطريق للمدرسة',
      );

      expect(req.latitude, equals(32.890000));
      expect(req.longitude, equals(13.190000));
      expect(req.toJson()['latitude'], equals(32.890000));
      expect(req.toJson()['longitude'], equals(13.190000));
    });

    // ── تدقيق خاص للنقطة 1 للمستخدم ──
    test('تدقيق 1: لا تتحدد المرحلة الأولى لو كان بعض الأطفال absent أو skipped', () {
      final stops = [
        makeStop(id: 1, type: 'home', seq: 1, status: 'absent', childId: 1),
        makeStop(id: 2, type: 'home', seq: 2, childId: 2),
        makeStop(id: 3, type: 'school', seq: 3),
      ];
      final children = [
        makeChild(childId: 1, status: 'absent', seq: 1),
        makeChild(childId: 2, status: 'pending', seq: 2),
      ];

      final phase = evaluateSmartTripPhase(stops: stops, childItems: children);
      // لأن طفلاً غائب ولم يصعد أحد، المرحلة الأولى غير صالحة
      expect(phase, isNot(equals(SmartTripPhase.beforePickup)));
    });

    // ── تدقيق خاص للنقطة 2 للمستخدم ──
    test('تدقيق 2: لا تتحدد المرحلة الثالثة لو كان جميع الطلاب absent/skipped (لم يصعد أحد)', () {
      final stops = [
        makeStop(id: 1, type: 'home', seq: 1, status: 'absent', childId: 1),
        makeStop(id: 2, type: 'home', seq: 2, status: 'skipped', childId: 2),
        makeStop(id: 3, type: 'school', seq: 3),
      ];
      final children = [
        makeChild(childId: 1, status: 'absent', seq: 1),
        makeChild(childId: 2, status: 'skipped', seq: 2),
      ];

      final phase = evaluateSmartTripPhase(stops: stops, childItems: children);
      // لا يوجد طلاب على متن الحافلة لإنزالهم في المدرسة -> لا توجه للمدارس
      expect(phase, isNot(equals(SmartTripPhase.headingToSchool)));
    });

    // ── تدقيق اكتمال الرحلة بالكامل ──
    test('تدقيق 3: اكتمال إنزال الطلاب بالمدارس -> لا تتحدد المرحلة الثالثة', () {
      final stops = [
        makeStop(id: 1, type: 'home', seq: 1, status: 'completed', childId: 1),
        makeStop(id: 2, type: 'school', seq: 2, status: 'completed'),
      ];
      final children = [
        makeChild(childId: 1, status: 'dropped_off', seq: 1),
      ];

      final phase = evaluateSmartTripPhase(stops: stops, childItems: children);
      expect(phase, isNull);
    });

    // ── تدقيق إعادة التعيين والرجوع للوضع الحقيقي ──
    test('10. reset() يلغي الإحداثيات المحاكية تماماً', () {
      mockProvider.updateSmartPhase(SmartTripPhase.duringPickup);
      expect(mockProvider.currentSmartPosition, isNotNull);

      mockProvider.reset();
      expect(mockProvider.currentSmartPosition, isNull);
      expect(mockProvider.currentSmartPhase, isNull);
    });
  });
}
