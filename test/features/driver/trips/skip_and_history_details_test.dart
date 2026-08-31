import 'package:flutter_test/flutter_test.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_history_model.dart';

void main() {
  group('Driver Trip History Details Contract Tests', () {
    test('Test 1 - Trip Details Parsing: تحليل تفاصيل الرحلة الجديدة (trip_id, trip_date, route_name, status)', () {
      final jsonDetails = {
        "trip_id": 1272,
        "trip_date": "2026-08-30",
        "route_name": "مسار صباحي - ذهاب وعودة",
        "status": "completed",
        "duration": 40,
        "distance": 15.5
      };

      final details = DriverTripHistoryDetailsModel.fromJson(jsonDetails);

      expect(details.tripId, equals(1272));
      expect(details.tripDate, equals('2026-08-30'));
      expect(details.routeName, equals('مسار صباحي - ذهاب وعودة'));
      expect(details.status, equals('completed'));
    });

    test('Test 2 - Summary Parsing: تحليل كائن ملخص الطلاب (total_students, picked_up, absent)', () {
      final jsonSummary = {
        "total_students": 3,
        "picked_up": 1,
        "absent": 2
      };

      final summary = TripHistorySummaryModel.fromJson(jsonSummary);

      expect(summary.totalStudents, equals(3));
      expect(summary.pickedUp, equals(1));
      expect(summary.absent, equals(2));
    });

    test('Test 3 - Child Completed: تحليل طفل مكتمل (status = completed, action_type = dropped_off, reason = null)', () {
      final jsonChild = {
        "child_id": 4068,
        "child_name": "علي محمد",
        "name": "علي محمد",
        "school": "مدرسة طرابلس المركزية",
        "school_name": "مدرسة طرابلس المركزية",
        "pickup_address": "الحي السكني",
        "dropoff_address": "مدرسة طرابلس المركزية",
        "pickup_time": "07:20",
        "dropoff_time": "07:45",
        "scanned_pickup_at": "2026-08-30 07:20:00",
        "scanned_dropoff_at": "2026-08-30 07:45:00",
        "status": "completed",
        "reason": null,
        "pickup_status": "completed",
        "dropoff_status": "completed",
        "action_type": "dropped_off",
        "scanned_at": "2026-08-30 07:45:00"
      };

      final child = TripHistoryChildModel.fromJson(jsonChild);

      expect(child.childId, equals(4068));
      expect(child.childName, equals('علي محمد'));
      expect(child.status, equals('completed'));
      expect(child.actionType, equals('dropped_off'));
      expect(child.reason, isNull);
      expect(child.isCompleted, isTrue);
    });

    test('Test 4 - Child Skipped: تحليل طفل تم تخطيه (status = skipped, pickup_status = skipped, action_type = skipped, reason = الشارع مغلق بسبب أعمال صيانة)', () {
      final jsonChild = {
        "child_id": 4069,
        "child_name": "سارة محمد",
        "name": "سارة محمد",
        "school": "مدرسة طرابلس المركزية",
        "school_name": "مدرسة طرابلس المركزية",
        "pickup_address": "الحي السكني",
        "dropoff_address": "مدرسة طرابلس المركزية",
        "pickup_time": null,
        "dropoff_time": null,
        "scanned_pickup_at": null,
        "scanned_dropoff_at": null,
        "status": "skipped",
        "reason": "الشارع مغلق بسبب أعمال صيانة",
        "pickup_status": "skipped",
        "dropoff_status": "pending",
        "action_type": "skipped",
        "scanned_at": "2026-08-30 07:25:00"
      };

      final child = TripHistoryChildModel.fromJson(jsonChild);

      expect(child.childId, equals(4069));
      expect(child.status, equals('skipped'));
      expect(child.pickupStatus, equals('skipped'));
      expect(child.actionType, equals('skipped'));
      expect(child.reason, equals('الشارع مغلق بسبب أعمال صيانة'));
      expect(child.isSkipped, isTrue);
    });

    test('Test 5 - Child Absent: تحليل طفل غائب (status = absent, pickup_status = absent, action_type = absent, reason = تم الإبلاغ عن الغياب من ولي الأمر)', () {
      final jsonChild = {
        "child_id": 4070,
        "child_name": "عمر محمد",
        "name": "عمر محمد",
        "school": "مدرسة طرابلس المركزية",
        "school_name": "مدرسة طرابلس المركزية",
        "pickup_address": "الحي السكني",
        "dropoff_address": "مدرسة طرابلس المركزية",
        "pickup_time": null,
        "dropoff_time": null,
        "scanned_pickup_at": null,
        "scanned_dropoff_at": null,
        "status": "absent",
        "reason": "تم الإبلاغ عن الغياب من ولي الأمر",
        "pickup_status": "absent",
        "dropoff_status": "pending",
        "action_type": "absent",
        "scanned_at": "2026-08-30 07:30:00"
      };

      final child = TripHistoryChildModel.fromJson(jsonChild);

      expect(child.childId, equals(4070));
      expect(child.status, equals('absent'));
      expect(child.pickupStatus, equals('absent'));
      expect(child.actionType, equals('absent'));
      expect(child.reason, equals('تم الإبلاغ عن الغياب من ولي الأمر'));
      expect(child.isAbsent, isTrue);
    });

    test('Test 6 - Reason Preservation: التأكد من الحفاظ على نص السبب لكل إجراء في الموديل دون تعديله أو تحريفه', () {
      final jsonChild = {
        "child_id": 2,
        "child_name": "طفل 2",
        "status": "skipped",
        "reason": "عطل مروري في الطريق المؤدي للمنزل"
      };

      final child = TripHistoryChildModel.fromJson(jsonChild);

      expect(child.reason, equals('عطل مروري في الطريق المؤدي للمنزل'));
    });

    test('Test 7 - Nullable Fields: التأكد من معالجة الحقول القابلة لـ null دون خطأ', () {
      final jsonChild = {
        "child_id": 101,
        "child_name": "سامي",
        "status": "pending",
        "reason": null,
        "pickup_time": null,
        "dropoff_time": null,
        "scanned_pickup_at": null,
        "scanned_dropoff_at": null,
        "scanned_at": null
      };

      final child = TripHistoryChildModel.fromJson(jsonChild);

      expect(child.reason, isNull);
      expect(child.pickupTime, isNull);
      expect(child.dropoffTime, isNull);
      expect(child.scannedPickupAt, isNull);
      expect(child.scannedDropoffAt, isNull);
      expect(child.scannedAt, isNull);
    });

    test('Test 8 - Distinction Test: التأكد من أن skipped لا يتحول إلى absent في الموديل', () {
      final jsonSkipped = {
        "child_id": 1,
        "child_name": "طفل 1",
        "status": "skipped",
        "action_type": "skipped"
      };

      final child = TripHistoryChildModel.fromJson(jsonSkipped);

      expect(child.isSkipped, isTrue);
      expect(child.isAbsent, isFalse);
      expect(child.status, isNot(equals('absent')));
    });

    test('Test 9 - Timestamps Parsing: تحليل actual_started_at و actual_completed_at بنجاح', () {
      final jsonDetails = {
        "trip_id": 1272,
        "trip_date": "2026-08-30",
        "route_name": "مسار صباحي",
        "status": "completed",
        "actual_started_at": "2026-08-30 07:15:00",
        "actual_completed_at": "2026-08-30 07:55:00",
        "duration": 40,
        "distance": 15.5
      };

      final details = DriverTripHistoryDetailsModel.fromJson(jsonDetails);

      expect(details.actualStartedAt, equals('2026-08-30 07:15:00'));
      expect(details.actualCompletedAt, equals('2026-08-30 07:55:00'));
    });

    test('Test 10 - Distance Parsing: قراءة المسافة distance كعدد عشري بنجاح', () {
      final jsonDetails = {
        "trip_id": 1272,
        "duration": 40,
        "distance": 15.5
      };

      final details = DriverTripHistoryDetailsModel.fromJson(jsonDetails);

      expect(details.distance, equals(15.5));
    });

    test('Test 11 - Action Type Parsing: تحليل action_type واستخراجه بنجاح', () {
      final jsonChild = {
        "child_id": 4068,
        "child_name": "علي",
        "status": "completed",
        "action_type": "dropped_off"
      };

      final child = TripHistoryChildModel.fromJson(jsonChild);

      expect(child.actionType, equals('dropped_off'));
    });

    test('Test 12 - Scanned At Parsing: قراءة scanned_at واستخراجه بنجاح', () {
      final jsonChild = {
        "child_id": 4068,
        "child_name": "علي",
        "status": "completed",
        "scanned_at": "2026-08-30 07:45:00"
      };

      final child = TripHistoryChildModel.fromJson(jsonChild);

      expect(child.scannedAt, equals('2026-08-30 07:45:00'));
    });
  });
}
