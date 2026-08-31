import 'package:flutter_test/flutter_test.dart';
import 'package:kids_transport/features/driver/trips/data/models/vehicle_breakdown_model.dart';

void main() {
  group('Vehicle Breakdown Request & Response Tests', () {
    test('Test 1 - Request toJson() يحتوي على جميع الحقول المطلوبة بالشكل الصريح', () {
      const request = VehicleBreakdownRequestModel(
        latitude: 32.885,
        longitude: 13.185,
        reason: 'عطل في المحرك وتوقف تام للمركبة في طريق الشط',
        accuracy: 5.2,
        speed: 0.0,
        address: 'طرابلس - طريق الشط بالقرب من جزيرة الميناء',
      );

      final json = request.toJson();

      expect(json['latitude'], equals(32.885));
      expect(json['longitude'], equals(13.185));
      expect(json['reason'], equals('عطل في المحرك وتوقف تام للمركبة في طريق الشط'));
      expect(json['accuracy'], equals(5.2));
      expect(json['speed'], equals(0.0));
      expect(json['address'], equals('طرابلس - طريق الشط بالقرب من جزيرة الميناء'));
    });

    test('Test 2 - Reason إدخال المستخدم يصل بدقة للطلب ولا يتم ضياعه أو استبداله بصيغة ثابتة', () {
      const customReason = 'انفجار في الإطار الخلفي الأيمن على الطريق السريع';
      const request = VehicleBreakdownRequestModel(
        latitude: 32.89,
        longitude: 13.17,
        reason: customReason,
        accuracy: 4.0,
        speed: 12.5,
      );

      expect(request.reason, equals(customReason));
      expect(request.toJson()['reason'], equals(customReason));
    });

    test('Test 3 - Response broadcasted parsing صحيح', () {
      final jsonResponse = {
        "status": "broadcasted",
        "message": "تم إرسال بلاغ الطوارئ وجاري تبليغ السائقين المتاحين",
        "trip_id": 142,
        "dispatch_id": 18,
        "breakdown_location": {
          "latitude": 32.885,
          "longitude": 13.185,
          "lat": 32.885,
          "lng": 13.185,
          "maps_url": "https://maps.google.com/?q=32.885,13.185"
        },
        "stranded_children_count": 2,
        "candidates_count": 2,
        "candidate_driver_ids": [5, 9],
        "trip_fare_amount": 9.1
      };

      final response = VehicleBreakdownResponseModel.fromJson(jsonResponse);

      expect(response.status, equals('broadcasted'));
      expect(response.isBroadcasted, isTrue);
      expect(response.message, equals('تم إرسال بلاغ الطوارئ وجاري تبليغ السائقين المتاحين'));
      expect(response.tripId, equals(142));
      expect(response.dispatchId, equals(18));
      expect(response.breakdownLocation?.latitude, equals(32.885));
      expect(response.breakdownLocation?.longitude, equals(13.185));
      expect(response.breakdownLocation?.mapsUrl, equals('https://maps.google.com/?q=32.885,13.185'));
      expect(response.strandedChildrenCount, equals(2));
      expect(response.candidatesCount, equals(2));
      expect(response.candidateDriverIds, equals([5, 9]));
      expect(response.tripFareAmount, equals(9.1));
    });

    test('Test 4 - Response no_substitutes_available parsing صحيح', () {
      final jsonResponse = {
        "status": "no_substitutes_available",
        "message": "لا يوجد سائقون بدلاء متاحون حالياً في المنطقة",
        "trip_id": 143,
        "dispatch_id": 19,
        "breakdown_location": {
          "latitude": 32.8872,
          "longitude": 13.1913,
          "lat": 32.8872,
          "lng": 13.1913,
          "maps_url": "https://maps.google.com/?q=32.8872,13.1913"
        },
        "stranded_children_count": 2,
        "candidates_count": 0
      };

      final response = VehicleBreakdownResponseModel.fromJson(jsonResponse);

      expect(response.status, equals('no_substitutes_available'));
      expect(response.isNoSubstitutes, isTrue);
      expect(response.message, equals('لا يوجد سائقون بدلاء متاحون حالياً في المنطقة'));
      expect(response.tripId, equals(143));
      expect(response.dispatchId, equals(19));
      expect(response.strandedChildrenCount, equals(2));
      expect(response.candidatesCount, equals(0));
      expect(response.candidateDriverIds, isEmpty);
    });

    test('Test 5 - Response success parsing صحيح مع dispatch = null', () {
      final jsonResponse = {
        "status": "success",
        "message": "تم تسجيل طوارئ التعطل بنجاح",
        "trip_id": 144,
        "breakdown_location": {
          "latitude": 32.885,
          "longitude": 13.185,
          "lat": 32.885,
          "lng": 13.185,
          "maps_url": "https://maps.google.com/?q=32.885,13.185"
        },
        "stranded_children_count": 0,
        "dispatch": null
      };

      final response = VehicleBreakdownResponseModel.fromJson(jsonResponse);

      expect(response.status, equals('success'));
      expect(response.isSuccess, isTrue);
      expect(response.message, equals('تم تسجيل طوارئ التعطل بنجاح'));
      expect(response.tripId, equals(144));
      expect(response.dispatchId, isNull);
      expect(response.strandedChildrenCount, equals(0));
      expect(response.dispatch, isNull);
    });
  });
}
