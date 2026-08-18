import 'package:flutter_test/flutter_test.dart';
import 'package:kids_transport/core/models/notification_model.dart';

void main() {
  group('NotificationModel JSON Parsing Tests', () {
    test('Should parse standard Laravel notification JSON correctly', () {
      final json = {
        'id': 'uuid-1234-5678',
        'type': 'trip_started',
        'title': 'بدء الرحلة',
        'message': 'تم بدء رحلتك الآن',
        'action_url': 'https://example.com',
        'entity_type': 'trip',
        'entity_id': '452',
        'screen': 'TRIP_DETAILS',
        'action': 'open_trip',
        'payload': {'foo': 'bar'},
        'read_at': '2026-08-14T19:30:00Z',
        'is_read': false,
        'created_at': '2026-08-14T19:00:00Z',
      };

      final model = NotificationModel.fromJson(json);

      expect(model.id, 'uuid-1234-5678');
      expect(model.type, 'trip_started');
      expect(model.title, 'بدء الرحلة');
      expect(model.message, 'تم بدء رحلتك الآن');
      expect(model.actionUrl, 'https://example.com');
      expect(model.entityType, 'trip');
      expect(model.entityId, '452');
      expect(model.screen, 'TRIP_DETAILS');
      expect(model.action, 'open_trip');
      expect(model.payload?['foo'], 'bar');
      expect(model.isRead, true); // read_at is not null
      expect(model.createdAt.year, 2026);
    });

    test('Should handle integer and string variations for entity_id safely', () {
      final jsonWithInt = {
        'id': 'uuid-1234',
        'entity_id': 452,
      };

      final model = NotificationModel.fromJson(jsonWithInt);
      expect(model.entityId, '452');
    });

    test('Should parse string-encoded payloads safely', () {
      final json = {
        'id': 'uuid-5678',
        'payload': '{"key": "value"}',
      };

      final model = NotificationModel.fromJson(json);
      expect(model.payload?['key'], 'value');
    });

    test('Should fallback safely on missing fields and malformed data', () {
      final json = {
        'id': null,
        'title': null,
        'payload': 'invalid-json-string',
      };

      final model = NotificationModel.fromJson(json);
      expect(model.id, '');
      expect(model.title, '');
      expect(model.payload, null);
    });
  });
}
