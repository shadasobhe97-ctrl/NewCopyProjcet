import 'package:flutter_test/flutter_test.dart';
import 'package:kids_transport/features/parent/addresses/data/models/address_model.dart';

void main() {
  group('AddressModel Tests', () {
    test('fromJson parses new backend contract with zone_id, zone_name, street_address', () {
      final json = {
        'id': 12,
        'title': 'المنزل الرئيسي',
        'street_address': 'شارع بن عاشور',
        'latitude': 32.8872,
        'longitude': 13.1913,
        'is_default': true,
        'zone_id': 5,
        'zone_name': 'حي الأندلس',
        'created_at': '2026-09-05T00:00:00.000000Z',
      };

      final model = AddressModel.fromJson(json);

      expect(model.id, '12');
      expect(model.title, 'المنزل الرئيسي');
      expect(model.streetAddress, 'شارع بن عاشور');
      expect(model.latitude, 32.8872);
      expect(model.longitude, 13.1913);
      expect(model.isDefault, true);
      expect(model.zoneId, 5);
      expect(model.zoneName, 'حي الأندلس');
      expect(model.createdAt, '2026-09-05T00:00:00.000000Z');

      // Compatibility getters
      expect(model.label, 'المنزل الرئيسي');
      expect(model.lat, 32.8872);
      expect(model.lng, 13.1913);
    });

    test('toJson generates strict contract payload without parent_id / user_id', () {
      final model = AddressModel(
        id: '12',
        title: 'المنزل الرئيسي',
        streetAddress: 'شارع بن عاشور',
        latitude: 32.8872,
        longitude: 13.1913,
        zoneId: 5,
        zoneName: 'حي الأندلس',
        isDefault: true,
      );

      final json = model.toJson();

      expect(json['title'], 'المنزل الرئيسي');
      expect(json['street_address'], 'شارع بن عاشور');
      expect(json['latitude'], 32.8872);
      expect(json['longitude'], 13.1913);
      expect(json['zone_id'], 5);
      expect(json['is_default'], true);

      // Must NOT contain parent_id, parentId, user_id
      expect(json.containsKey('parent_id'), isFalse);
      expect(json.containsKey('parentId'), isFalse);
      expect(json.containsKey('user_id'), isFalse);
      expect(json.containsKey('userId'), isFalse);
    });

    test('toDisplayMap includes all fields for UI rendering and caching', () {
      final model = AddressModel(
        id: '12',
        title: 'المنزل الرئيسي',
        streetAddress: 'شارع بن عاشور',
        latitude: 32.8872,
        longitude: 13.1913,
        zoneId: 5,
        zoneName: 'حي الأندلس',
        isDefault: true,
        createdAt: '2026-09-05T00:00:00.000000Z',
      );

      final map = model.toDisplayMap();

      expect(map['id'], '12');
      expect(map['title'], 'المنزل الرئيسي');
      expect(map['street_address'], 'شارع بن عاشور');
      expect(map['latitude'], 32.8872);
      expect(map['longitude'], 13.1913);
      expect(map['zone_id'], 5);
      expect(map['zone_name'], 'حي الأندلس');
      expect(map['is_default'], true);
      expect(map['created_at'], '2026-09-05T00:00:00.000000Z');
    });
  });
}
