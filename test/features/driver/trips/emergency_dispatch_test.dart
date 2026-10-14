import 'package:flutter_test/flutter_test.dart';
import 'package:kids_transport/features/driver/trips/data/models/emergency_dispatch_model.dart';
import 'package:kids_transport/core/models/notification_model.dart';

void main() {
  group('Emergency Dispatch Data Parsing Tests', () {
    test('1. Test parsing of dispatch JSON with dynamic Map types (simulating Dio)', () {
      final dynamicJson = <dynamic, dynamic>{
        'id': 15,
        'trip_id': 42,
        'status': 'broadcasted',
        'breakdown_lat': 32.885,
        'breakdown_lng': 13.185,
        'trip_fare_amount': 25.5,
        'stranded_children_count': 3,
        'reason': 'عطل في المحرك',
        'original_driver': <dynamic, dynamic>{
          'id': 7,
          'name': 'محمد علي',
          'phone': '0912345678',
        },
        'trip': <dynamic, dynamic>{
          'id': 42,
          'trip_type': 'morning',
          'status': 'suspended_breakdown',
          'stops': <dynamic>[
            <dynamic, dynamic>{
              'id': 101,
              'stop_type': 'home',
              'sequence_order': 1,
              'status': 'pending',
              'label': 'محطة 1',
              'lat': 32.88,
              'lng': 13.18,
            },
          ],
        },
      };

      final typedMap = Map<String, dynamic>.from(dynamicJson);
      final model = EmergencyDispatchModel.fromJson(typedMap);

      expect(model.id, equals(15));
      expect(model.tripId, equals(42));
      expect(model.status, equals('broadcasted'));
      expect(model.isBroadcasted, isTrue);
      expect(model.breakdownLat, equals(32.885));
      expect(model.breakdownLng, equals(13.185));
      expect(model.tripFareAmount, equals(25.5));
      expect(model.strandedChildrenCount, equals(3));
      expect(model.originalDriver?.name, equals('محمد علي'));
      expect(model.trip?.stops.length, equals(1));
      expect(model.trip?.stops.first.id, equals(101));
    });

    test('2. Test list extraction logic with Map<dynamic, dynamic> elements', () {
      final dataResponse = {
        'status': 'success',
        'data': [
          <dynamic, dynamic>{
            'id': 1,
            'trip_id': 10,
            'status': 'broadcasted',
            'breakdown_lat': 32.88,
            'breakdown_lng': 13.18,
            'trip_fare_amount': 15.0,
          },
          <dynamic, dynamic>{
            'id': 2,
            'trip_id': 11,
            'status': 'broadcasted',
            'breakdown_lat': 32.89,
            'breakdown_lng': 13.19,
            'trip_fare_amount': 20.0,
          },
        ],
      };

      final rawList = dataResponse['data'] as List;
      final parsedList = rawList
          .whereType<Map>()
          .map((e) => EmergencyDispatchModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      expect(parsedList.length, equals(2));
      expect(parsedList[0].id, equals(1));
      expect(parsedList[1].id, equals(2));
    });

    test('3. Test list extraction when wrapped in dispatches key', () {
      final dispatchesResponse = {
        'status': 'success',
        'dispatches': [
          <dynamic, dynamic>{
            'id': 99,
            'trip_id': 200,
            'status': 'broadcasted',
            'breakdown_lat': 32.90,
            'breakdown_lng': 13.20,
            'trip_fare_amount': 30.0,
          },
        ],
      };

      List<dynamic> rawList = [];
      if (dispatchesResponse['dispatches'] is List) {
        rawList = dispatchesResponse['dispatches'] as List;
      }

      final parsedList = rawList
          .whereType<Map>()
          .map((e) => EmergencyDispatchModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      expect(parsedList.length, equals(1));
      expect(parsedList[0].id, equals(99));
    });

    test('4. Test notification parsing when wrapped in Laravel data object', () {
      final laravelNotification = {
        'id': 'uuid-1234',
        'type': 'App\\Notifications\\EmergencyDispatchNotification',
        'data': {
          'title': 'طلب طوارئ عاجل',
          'message': 'حافلة معطلة بحاجة لبديل',
          'screen': 'EMERGENCY_DISPATCH',
          'dispatch_id': 18,
          'entity_id': 18,
          'entity_type': 'emergency_dispatch',
        },
        'read_at': null,
        'created_at': '2026-10-12T12:00:00Z',
      };

      final notification = NotificationModel.fromJson(laravelNotification);

      expect(notification.id, equals('uuid-1234'));
      expect(notification.title, equals('طلب طوارئ عاجل'));
      expect(notification.message, equals('حافلة معطلة بحاجة لبديل'));
      expect(notification.screen, equals('EMERGENCY_DISPATCH'));
      expect(notification.entityId, equals('18'));
      expect(notification.entityType, equals('emergency_dispatch'));
      expect(notification.payload?['dispatch_id'], equals(18));
    });

    test('5. Test parsing of substitute_trip_id and substitute_driver_id from Laravel response', () {
      final json = <String, dynamic>{
        'id': 25,
        'trip_id': 60,
        'status': 'accepted',
        'substitute_trip_id': 188,
        'substitute_driver_id': 9,
        'breakdown_lat': 32.88,
        'breakdown_lng': 13.18,
        'trip_fare_amount': 35.0,
      };

      final model = EmergencyDispatchModel.fromJson(json);

      expect(model.id, equals(25));
      expect(model.status, equals('accepted'));
      expect(model.isAccepted, isTrue);
      expect(model.substituteTripId, equals(188));
      expect(model.substituteDriverId, equals(9));
    });

    test('6. Verify driver identity matching logic for accepted emergency dispatch', () {
      final myDispatchJson = <String, dynamic>{
        'id': 30,
        'trip_id': 70,
        'status': 'accepted',
        'substitute_trip_id': 200,
        'substitute_driver_id': 9,
        'breakdown_lat': 32.88,
        'breakdown_lng': 13.18,
        'trip_fare_amount': 25.0,
      };

      final otherDispatchJson = <String, dynamic>{
        'id': 31,
        'trip_id': 71,
        'status': 'accepted',
        'substitute_trip_id': 201,
        'substitute_driver_id': 14,
        'breakdown_lat': 32.88,
        'breakdown_lng': 13.18,
        'trip_fare_amount': 25.0,
      };

      final myDispatch = EmergencyDispatchModel.fromJson(myDispatchJson);
      final otherDispatch = EmergencyDispatchModel.fromJson(otherDispatchJson);

      const currentDriverId = 9;

      final isMine = myDispatch.isAccepted &&
          myDispatch.substituteDriverId != null &&
          myDispatch.substituteDriverId == currentDriverId;

      final isOther = otherDispatch.isAccepted &&
          (otherDispatch.substituteDriverId != currentDriverId);

      expect(isMine, isTrue);
      expect(myDispatch.substituteTripId, equals(200));

      expect(isOther, isTrue);
    });

    test('7. Test Laravel paginated response structure extraction', () {
      final paginatedResponse = {
        'status': 'success',
        'data': {
          'current_page': 1,
          'data': [
            {
              'id': 50,
              'trip_id': 100,
              'status': 'broadcasted',
              'breakdown_lat': 32.88,
              'breakdown_lng': 13.18,
              'trip_fare_amount': 35.0,
            },
          ],
          'total': 1,
        },
      };

      final inner = paginatedResponse['data'] as Map;
      final rawList = inner['data'] as List;
      final dispatches = rawList
          .whereType<Map>()
          .map((e) => EmergencyDispatchModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      expect(dispatches.length, equals(1));
      expect(dispatches.first.id, equals(50));
      expect(dispatches.first.tripFareAmount, equals(35.0));
    });

    test('8. Test single dispatch object response structure', () {
      final singleDispatchResponse = {
        'status': 'success',
        'data': {
          'id': 55,
          'trip_id': 105,
          'status': 'broadcasted',
          'breakdown_lat': 32.88,
          'breakdown_lng': 13.18,
          'trip_fare_amount': 40.0,
        },
      };

      final inner = singleDispatchResponse['data'] as Map;
      expect(inner.containsKey('id'), isTrue);
      final model = EmergencyDispatchModel.fromJson(Map<String, dynamic>.from(inner));
      expect(model.id, equals(55));
      expect(model.tripId, equals(105));
    });
  });
}
