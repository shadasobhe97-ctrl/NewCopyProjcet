import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_history_model.dart';

void main() {
  group('Driver Trip History Backend Contract Tests', () {
    test('Test 1 - Response طبيعي: تحليل status و data و pagination بنجاح', () {
      final jsonResponse = {
        "status": "success",
        "data": [
          {
            "trip_id": 1,
            "trip_date": "2026-08-27",
            "route_name": "مسار الذهاب الصباحي - حي الأندلس إلى مدرسة الجيل الجديد",
            "status": "completed",
            "duration": 32
          }
        ],
        "pagination": {
          "current_page": 1,
          "total_pages": 1,
          "last_page": 1,
          "per_page": 15,
          "total": 1,
          "has_more": false
        }
      };

      final responseModel = DriverTripHistoryResponseModel.fromJson(jsonResponse);

      expect(responseModel.status, equals('success'));
      expect(responseModel.data.length, equals(1));
      expect(responseModel.pagination.currentPage, equals(1));
      expect(responseModel.pagination.total, equals(1));
      expect(responseModel.pagination.hasMore, isFalse);
    });

    test('Test 2 - Trip History: تحليل حقول trip_id, trip_date, route_name, status, duration', () {
      final jsonTrip = {
        "trip_id": 1,
        "trip_date": "2026-08-27",
        "route_name": "مسار الذهاب الصباحي",
        "status": "completed",
        "duration": 32
      };

      final trip = DriverTripHistoryModel.fromJson(jsonTrip);

      expect(trip.tripId, equals(1));
      expect(trip.tripDate, equals('2026-08-27'));
      expect(trip.routeName, equals('مسار الذهاب الصباحي'));
      expect(trip.status, equals('completed'));
      expect(trip.duration, equals(32));
    });

    test('Test 3 - Pagination: قراءة current_page, total_pages, last_page, per_page, total, has_more', () {
      final jsonPagination = {
        "current_page": 2,
        "total_pages": 5,
        "last_page": 5,
        "per_page": 15,
        "total": 75,
        "has_more": true
      };

      final pagination = PaginationModel.fromJson(jsonPagination);

      expect(pagination.currentPage, equals(2));
      expect(pagination.totalPages, equals(5));
      expect(pagination.lastPage, equals(5));
      expect(pagination.perPage, equals(15));
      expect(pagination.total, equals(75));
      expect(pagination.hasMore, isTrue);
    });

    test('Test 4 - Empty Result: التعامل المباشر مع data = [] و total = 0 دون خطأ', () {
      final jsonResponse = {
        "status": "success",
        "data": [],
        "pagination": {
          "current_page": 1,
          "total_pages": 1,
          "last_page": 1,
          "per_page": 15,
          "total": 0,
          "has_more": false
        }
      };

      final responseModel = DriverTripHistoryResponseModel.fromJson(jsonResponse);

      expect(responseModel.status, equals('success'));
      expect(responseModel.data, isEmpty);
      expect(responseModel.pagination.total, equals(0));
      expect(responseModel.pagination.hasMore, isFalse);
    });

    test('Test 5 - Date Filter: إعداد معلمة الاستعلام date=2026-08-27 بالشكل المطلوب', () {
      const selectedDate = '2026-08-27';
      final query = <String, dynamic>{};
      if (selectedDate.isNotEmpty) query['date'] = selectedDate;

      expect(query.containsKey('date'), isTrue);
      expect(query['date'], equals('2026-08-27'));
    });

    test('Test 6 - Date Format: التأكد من تنسيق التاريخ بصيغة yyyy-MM-dd', () {
      final date = DateTime(2026, 8, 27);
      final formatted = DateFormat('yyyy-MM-dd').format(date);

      expect(formatted, equals('2026-08-27'));
    });
  });
}
