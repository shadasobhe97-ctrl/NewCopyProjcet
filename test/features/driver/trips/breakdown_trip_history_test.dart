import 'package:flutter_test/flutter_test.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_history_model.dart';

void main() {
  group('Driver Trip History Breakdown & Substitute Driver Tests', () {
    test('الحالة الأولى: رحلة مكتملة طبيعياً بدون عطل وبدون سائق بديل', () {
      final jsonTrip = {
        "trip_id": 101,
        "trip_date": "2026-10-21",
        "route_name": "مسار النوفليين إلى مدرسة المستقبل",
        "status": "completed",
        "status_text": "رحلة مكتملة",
        "status_label": "مكتملة",
        "is_breakdown": false,
        "suspension_reason": null,
        "duration": 35,
        "substitute_driver": null,
      };

      final trip = DriverTripHistoryModel.fromJson(jsonTrip);

      expect(trip.tripId, equals(101));
      expect(trip.status, equals('completed'));
      expect(trip.statusLabel, equals('مكتملة'));
      expect(trip.statusText, equals('رحلة مكتملة'));
      expect(trip.isBreakdown, isFalse);
      expect(trip.suspensionReason, isNull);
      expect(trip.substituteDriver, isNull);
      expect(trip.duration, equals(35));
    });

    test('الحالة الثانية: رحلة متعطلة دون سائق بديل (suspended_breakdown)', () {
      final jsonTrip = {
        "trip_id": 102,
        "trip_date": "2026-10-21",
        "route_name": "مسار قرقارش إلى مدرسة طرابلس",
        "status": "suspended_breakdown",
        "status_text": "رحلة معطلة",
        "status_label": "معطلة",
        "is_breakdown": true,
        "suspension_reason": "عطل ميكانيكي مفاجئ في الحافلة",
        "duration": 20,
        "substitute_driver": null,
      };

      final trip = DriverTripHistoryModel.fromJson(jsonTrip);

      expect(trip.tripId, equals(102));
      expect(trip.status, equals('suspended_breakdown'));
      expect(trip.statusLabel, equals('معطلة'));
      expect(trip.statusText, equals('رحلة معطلة'));
      expect(trip.isBreakdown, isTrue);
      expect(trip.suspensionReason, equals('عطل ميكانيكي مفاجئ في الحافلة'));
      expect(trip.substituteDriver, isNull);
    });

    test('الحالة الثالثة: رحلة متعطلة مع سائق بديل مرتبط بمهمة الطوارئ', () {
      final jsonTrip = {
        "trip_id": 103,
        "trip_date": "2026-10-21",
        "route_name": "مسار فشلوم إلى مدرسة المعرفة",
        "status": "suspended_breakdown",
        "status_text": "رحلة معطلة",
        "status_label": "معطلة",
        "is_breakdown": true,
        "suspension_reason": "بنشر في الإطار الخلفي",
        "duration": 18,
        "substitute_driver": {
          "id": 909,
          "name": "محمود البديل",
          "phone": "0912345678"
        },
      };

      final trip = DriverTripHistoryModel.fromJson(jsonTrip);

      expect(trip.tripId, equals(103));
      expect(trip.status, equals('suspended_breakdown'));
      expect(trip.isBreakdown, isTrue);
      expect(trip.suspensionReason, equals('بنشر في الإطار الخلفي'));
      expect(trip.substituteDriver, isNotNull);
      expect(trip.substituteDriver!.id, equals(909));
      expect(trip.substituteDriver!.name, equals('محمود البديل'));
      expect(trip.substituteDriver!.phone, equals('0912345678'));
    });

    test('الحالة الرابعة: تفاصيل رحلة سابقة متعطلة مع السائق البديل وملخص الطلاب', () {
      final jsonDetails = {
        "trip_id": 1390,
        "trip_date": "2026-10-21",
        "route_name": "مسار الأندلس إلى مدرسة الجيل",
        "status": "suspended_breakdown",
        "status_text": "رحلة معطلة",
        "status_label": "معطلة",
        "is_breakdown": true,
        "suspension_reason": "ارتفاع درجة حرارة المحرك",
        "actual_started_at": "2026-10-21 07:10:00",
        "actual_completed_at": null,
        "duration": 25,
        "distance": 8.4,
        "substitute_driver": {
          "id": 915,
          "name": "خالد أحمد",
          "phone": "0923456789"
        },
        "summary": {
          "total_students": 4,
          "picked_up": 2,
          "absent": 2
        },
        "children": [
          {
            "child_id": 501,
            "child_name": "أحمد سالم",
            "name": "أحمد سالم",
            "school": "مدرسة الجيل",
            "school_name": "مدرسة الجيل",
            "pickup_address": "شارع النصر",
            "dropoff_address": "مدرسة الجيل",
            "pickup_time": "07:18",
            "dropoff_time": null,
            "scanned_pickup_at": "2026-10-21 07:18:00",
            "scanned_dropoff_at": null,
            "status": "picked_up",
            "reason": null,
            "pickup_status": "completed",
            "dropoff_status": "pending",
            "action_type": "picked_up",
            "scanned_at": "2026-10-21 07:18:00"
          }
        ]
      };

      final details = DriverTripHistoryDetailsModel.fromJson(jsonDetails);

      expect(details.tripId, equals(1390));
      expect(details.status, equals('suspended_breakdown'));
      expect(details.statusLabel, equals('معطلة'));
      expect(details.statusText, equals('رحلة معطلة'));
      expect(details.isBreakdown, isTrue);
      expect(details.suspensionReason, equals('ارتفاع درجة حرارة المحرك'));
      expect(details.actualStartedAt, equals('2026-10-21 07:10:00'));
      expect(details.actualCompletedAt, isNull);
      expect(details.distance, equals(8.4));
      expect(details.duration, equals(25));
      expect(details.substituteDriver, isNotNull);
      expect(details.substituteDriver!.id, equals(915));
      expect(details.substituteDriver!.name, equals('خالد أحمد'));
      expect(details.substituteDriver!.phone, equals('0923456789'));
      expect(details.summary.totalStudents, equals(4));
      expect(details.summary.pickedUp, equals(2));
      expect(details.summary.absent, equals(2));
      expect(details.children.length, equals(1));
      expect(details.children.first.childName, equals('أحمد سالم'));
      expect(details.children.first.pickupStatus, equals('completed'));
    });

    test('الحالة الخامسة: فلترة التاريخ وصيغة الاستعلام دون أخطاء', () {
      const selectedDate = '2026-10-21';
      final query = <String, dynamic>{};
      if (selectedDate.isNotEmpty) query['date'] = selectedDate;

      expect(query.containsKey('date'), isTrue);
      expect(query['date'], matches(r'^\d{4}-\d{2}-\d{2}$'));
      expect(query['date'], equals('2026-10-21'));
    });

    test('حالة أمان التوافق: قراءة استجابة قديمة بدون حقول العطل يعيد قيم افتراضية آمنة', () {
      final legacyJson = {
        "trip_id": 99,
        "trip_date": "2026-10-20",
        "route_name": "مسار قديم",
        "status": "completed",
        "duration": 40,
      };

      final trip = DriverTripHistoryModel.fromJson(legacyJson);
      expect(trip.status, equals('completed'));
      expect(trip.isBreakdown, isFalse);
      expect(trip.statusLabel, equals('مكتملة'));
      expect(trip.statusText, equals('رحلة مكتملة'));
      expect(trip.suspensionReason, isNull);
      expect(trip.substituteDriver, isNull);
    });
  });
}
