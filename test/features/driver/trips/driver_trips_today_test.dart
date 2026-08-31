import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_model.dart';

void main() {
  group('Driver Trips Today Backend Contract Tests', () {
    test('تاريخ الجهاز المحلي يتم تنسيقه بالشكل yyyy-MM-dd', () {
      final now = DateTime.now(); // local device time
      final formatted = DateFormat('yyyy-MM-dd').format(now);

      expect(formatted, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      expect(formatted, equals('${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}'));
    });

    test('تحليل استجابة Today Trips الجديدة من الباك إند', () {
      final jsonResponse = {
        "status": "success",
        "date": "2026-08-30",
        "data": [
          {
            "trip_id": 1,
            "route_id": 10,
            "route_name": "مسار الصباح",
            "trip_type": "Morning",
            "trip_date": "2026-08-30",
            "date": "2026-08-30",
            "status": "scheduled",
            "children_count": 5,
            "schools_count": 2,
            "estimated_duration": 45,
            "recommended_departure": "07:00",
            "started_at": null
          }
        ]
      };

      final responseModel = DriverTripsTodayResponseModel.fromJson(jsonResponse);

      expect(responseModel.status, equals('success'));
      expect(responseModel.date, equals('2026-08-30'));
      expect(responseModel.trips.length, equals(1));

      final trip = responseModel.trips.first;
      expect(trip.tripId, equals(1));
      expect(trip.routeName, equals('مسار الصباح'));
      expect(trip.tripDate, equals('2026-08-30'));
      expect(trip.date, equals('2026-08-30'));
      expect(trip.status, equals('scheduled'));
      expect(trip.isPending, isTrue); // scheduled ➔ isPending
    });
  });
}
