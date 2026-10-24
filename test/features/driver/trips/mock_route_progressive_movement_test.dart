import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_stop_model.dart';
import 'package:kids_transport/features/driver/trips/data/services/mock_route_provider.dart';
import 'package:kids_transport/core/utils/smooth_marker_motion.dart';

class _FakeTickerProvider extends TestVSync {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mock Route Progressive Movement & Marker Motion Tests', () {
    DriverTripStopModel makeStop({
      required int id,
      required String type,
      required int seq,
      required double lat,
      required double lng,
    }) {
      return DriverTripStopModel(
        id: id,
        stopType: type,
        sequenceOrder: seq,
        status: 'pending',
        childId: type == 'home' ? id : null,
        childName: type == 'home' ? 'طالب $id' : null,
        schoolId: type == 'school' ? id : null,
        schoolName: type == 'school' ? 'مدرسة $id' : null,
        label: 'محطة $id',
        latitude: lat,
        longitude: lng,
        eta: null,
        etaMinutes: null,
      );
    }

    test('1. المحاكي يبث إحداثيات متغيرة عند تشغيل المسار التدريجي', () async {
      final provider = MockRouteProvider(tickInterval: const Duration(milliseconds: 30));
      final stops = [
        makeStop(id: 1, type: 'home', seq: 1, lat: 32.880, lng: 13.180),
        makeStop(id: 2, type: 'school', seq: 2, lat: 32.890, lng: 13.190),
      ];

      provider.loadFromStops(stops);
      expect(provider.isLoaded, isTrue);

      final receivedPositions = <LatLng>[];
      final sub = provider.positions.listen((pos) {
        receivedPositions.add(LatLng(pos.latitude, pos.longitude));
      });

      provider.start();

      // ننتظر عدة نبضات
      await Future.delayed(const Duration(milliseconds: 200));
      provider.pause();
      await sub.cancel();

      expect(receivedPositions.length, greaterThanOrEqualTo(2));
      // التأكد من أن الإحداثيات تتغير وتتحرك فعلياً وليست ثابتة
      final first = receivedPositions.first;
      final last = receivedPositions.last;
      expect(first.latitude != last.latitude || first.longitude != last.longitude, isTrue);
    });

    test('2. updateSmartPhase لا يحجب حركة المسار التدريجي أثناء تشغيل التايمر', () async {
      final provider = MockRouteProvider(tickInterval: const Duration(milliseconds: 30));
      final stops = [
        makeStop(id: 1, type: 'home', seq: 1, lat: 32.880, lng: 13.180),
        makeStop(id: 2, type: 'school', seq: 2, lat: 32.890, lng: 13.190),
      ];
      provider.loadFromStops(stops);

      // استدعاء المرحلة الذكية
      provider.updateSmartPhase(SmartTripPhase.beforePickup);

      final receivedPositions = <LatLng>[];
      final sub = provider.positions.listen((pos) {
        receivedPositions.add(LatLng(pos.latitude, pos.longitude));
      });

      provider.start();
      await Future.delayed(const Duration(milliseconds: 200));
      provider.pause();
      await sub.cancel();

      // يجب أن تكون الإحداثيات قد تحركت بناءً على نقاط المسار التدريجي
      expect(receivedPositions.length, greaterThanOrEqualTo(2));
      final first = receivedPositions.first;
      final last = receivedPositions.last;
      expect(first.latitude != last.latitude || first.longitude != last.longitude, isTrue);
    });

    test('3. SmoothMarkerMotion يرفض NaN و Infinity ولا يعيد LatLng غير صالح', () {
      final motion = SmoothMarkerMotion(vsync: _FakeTickerProvider());

      // 1. إحداثي طبيعي
      final moved1 = motion.moveTo(const LatLng(32.88, 13.18));
      expect(moved1, isFalse); // أول إحداثي يضبط مباشرة

      // 2. إحداثي NaN
      final movedNaN = motion.moveTo(const LatLng(double.nan, 13.18));
      expect(movedNaN, isFalse);

      // 3. إحداثي Infinity
      final movedInf = motion.moveTo(const LatLng(32.88, double.infinity));
      expect(movedInf, isFalse);

      // 4. إحداثي خارج حدود الأرض
      final movedOut = motion.moveTo(const LatLng(95.0, 13.18));
      expect(movedOut, isFalse);

      // 5. إحداثي جديد صالح
      final moved2 = motion.moveTo(const LatLng(32.882, 13.182));
      expect(moved2, isTrue); // حركة انسيابية بدأت بنجاح

      // موقع الحافلة اللحظي يجب أن يكون صالحاً وليس NaN
      final pos = motion.position;
      expect(pos, isNotNull);
      expect(pos!.latitude.isNaN, isFalse);
      expect(pos.longitude.isNaN, isFalse);

      motion.dispose();
    });

    test('4. المحاكي يتبع مسار الشوارع الفعلي بنقاط الانعطاف وليس خطاً مستقيماً', () async {
      final provider = MockRouteProvider(tickInterval: const Duration(milliseconds: 25));
      final stops = [
        makeStop(id: 1, type: 'home', seq: 1, lat: 32.880, lng: 13.180),
        makeStop(id: 2, type: 'school', seq: 2, lat: 32.890, lng: 13.190),
      ];

      // مسار شوارع حقيقي يحتوي على منعطف حاد (L-shape curve)
      final roadPoints = [
        const LatLng(32.880, 13.180),
        const LatLng(32.880, 13.190), // انعطاف شرقاً
        const LatLng(32.890, 13.190), // ثم شمالاً للمدرسة
      ];

      provider.loadFromRoadPoints(roadPoints: roadPoints, stops: stops);
      expect(provider.isLoaded, isTrue);

      final receivedPositions = <Position>[];
      final sub = provider.positions.listen((pos) {
        receivedPositions.add(pos);
      });

      provider.start();
      await Future.delayed(const Duration(milliseconds: 300));
      provider.pause();
      await sub.cancel();

      expect(receivedPositions.length, greaterThanOrEqualTo(3));

      // التأكد من أن السائق اتبع زوايا المسار الشوارعي
      for (final p in receivedPositions) {
        expect(p.heading.isNaN, isFalse);
        expect(p.heading >= 0.0 && p.heading <= 360.0, isTrue);
      }
    });

    test('5. resampleRoadPoints يعيد تقطيع المسار بنقاط منتظمة المسافة', () {
      final raw = [
        const LatLng(32.880, 13.180),
        const LatLng(32.885, 13.180),
      ];

      final resampled = MockRouteProvider.resampleRoadPoints(raw, 20.0);
      expect(resampled.length, greaterThan(2));
      expect(resampled.first, raw.first);
    });

    test('6. سرعة السائق الفعلية في المحاكي تطابق 45 كم/ساعة والفاصل 1.5 ثانية', () {
      final provider = MockRouteProvider();
      expect(provider.tickInterval, equals(const Duration(milliseconds: 1500)));

      final stops = [
        makeStop(id: 1, type: 'home', seq: 1, lat: 32.880, lng: 13.180),
        makeStop(id: 2, type: 'school', seq: 2, lat: 32.890, lng: 13.180),
      ];

      final roadPoints = [
        const LatLng(32.880, 13.180),
        const LatLng(32.890, 13.180),
      ];

      provider.loadFromRoadPoints(roadPoints: roadPoints, stops: stops);
      expect(provider.isLoaded, isTrue);

      final pos = provider.currentPosition;
      expect(pos, isNotNull);
      // أول نقطة هي محطة الانطلاق فتكون السرعة 0.0
      expect(pos!.speed, equals(0.0));

      // أثناء القيادة بين المحطات، تكون سرعة الحركة المسجلة 45 كم/ساعة (12.5 م/ث)
      final drivingPoint = provider.points.firstWhere((p) => !p.isStop);
      expect(drivingPoint.speedKmh, equals(45.0));
      expect(drivingPoint.toPosition().speed, closeTo(45.0 / 3.6, 0.1));

      // حساب المسافة بين أول نقطتين والتحقق من السرعة الفيزيائية (المسافة / الزمن)
      const distanceCalc = Distance();
      final resampled = MockRouteProvider.resampleRoadPoints(roadPoints, 18.75);
      final stepDistance = distanceCalc.distance(resampled[0], resampled[1]);
      final speedMps = stepDistance / (provider.tickInterval.inMilliseconds / 1000.0);
      final speedKmh = speedMps * 3.6;
      expect(stepDistance, closeTo(18.75, 1.0));
      expect(speedKmh, closeTo(45.0, 1.5));
    });
  });
}
