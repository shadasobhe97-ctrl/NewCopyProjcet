import 'package:flutter_test/flutter_test.dart';
import 'package:kids_transport/core/utils/app_image_helper.dart';

void main() {
  group('AppImageHelper Unit Tests', () {
    final serverBase = AppImageHelper.serverBaseUrl;

    test('1. resolveUrl handles null, empty, and invalid string placeholders', () {
      expect(AppImageHelper.resolveUrl(null), isNull);
      expect(AppImageHelper.resolveUrl(''), isNull);
      expect(AppImageHelper.resolveUrl('   '), isNull);
      expect(AppImageHelper.resolveUrl('null'), isNull);
      expect(AppImageHelper.resolveUrl('NULL'), isNull);
      expect(AppImageHelper.resolveUrl('undefined'), isNull);
      expect(AppImageHelper.resolveUrl('none'), isNull);
    });

    test('2. resolveUrl preserves assets, blob, and data URIs', () {
      expect(
        AppImageHelper.resolveUrl('assets/images/ligth_logo.png'),
        equals('assets/images/ligth_logo.png'),
      );
      expect(
        AppImageHelper.resolveUrl('blob:http://localhost:3000/uuid'),
        equals('blob:http://localhost:3000/uuid'),
      );
      expect(
        AppImageHelper.resolveUrl('data:image/png;base64,iVBORw0KGgoAAAANSUhEUg=='),
        equals('data:image/png;base64,iVBORw0KGgoAAAANSUhEUg=='),
      );
    });

    test('3. resolveUrl correctly builds relative URLs and strips leading/duplicate storage', () {
      // Relative path with leading slash
      expect(
        AppImageHelper.resolveUrl('/storage/children/child_1.png'),
        equals('$serverBase/storage/children/child_1.png'),
      );

      // Relative path without leading slash
      expect(
        AppImageHelper.resolveUrl('storage/children/child_1.png'),
        equals('$serverBase/storage/children/child_1.png'),
      );

      // Duplicate storage in relative path
      expect(
        AppImageHelper.resolveUrl('/storage/storage/children/child_1.png'),
        equals('$serverBase/storage/children/child_1.png'),
      );
      expect(
        AppImageHelper.resolveUrl('storage/storage/children/child_1.png'),
        equals('$serverBase/storage/children/child_1.png'),
      );
    });

    test('4. resolveUrl correctly replaces localhost and 127.0.0.1 with active serverHost', () {
      expect(
        AppImageHelper.resolveUrl('http://localhost:8000/storage/avatar.jpg'),
        equals('$serverBase/storage/avatar.jpg'),
      );
      expect(
        AppImageHelper.resolveUrl('http://127.0.0.1:8000/storage/avatar.jpg'),
        equals('$serverBase/storage/avatar.jpg'),
      );
      expect(
        AppImageHelper.resolveUrl('http://localhost:8000/storage/storage/avatar.jpg'),
        equals('$serverBase/storage/avatar.jpg'),
      );
    });

    test('5. resolveUrl preserves query parameters', () {
      expect(
        AppImageHelper.resolveUrl('/storage/avatar.jpg?v=2&size=small'),
        equals('$serverBase/storage/avatar.jpg?v=2&size=small'),
      );
      expect(
        AppImageHelper.resolveUrl('http://localhost:8000/storage/avatar.jpg?token=xyz'),
        equals('$serverBase/storage/avatar.jpg?token=xyz'),
      );
    });

    test('6. resolveUrl preserves valid external HTTPS URLs without domain alteration', () {
      const externalUrl = 'https://images.unsplash.com/photo-1544526226-d4568090ddb8?q=80';
      expect(AppImageHelper.resolveUrl(externalUrl), equals(externalUrl));
    });

    test('7. isValidImageUrl filters out nulls, empty strings, and default placeholders', () {
      expect(AppImageHelper.isValidImageUrl(null), isFalse);
      expect(AppImageHelper.isValidImageUrl(''), isFalse);
      expect(AppImageHelper.isValidImageUrl('null'), isFalse);
      expect(AppImageHelper.isValidImageUrl('undefined'), isFalse);
      expect(AppImageHelper.isValidImageUrl('none'), isFalse);
      expect(AppImageHelper.isValidImageUrl('/storage/default-child.png'), isFalse);
      expect(AppImageHelper.isValidImageUrl('assets/images/default.png'), isFalse);
      expect(AppImageHelper.isValidImageUrl('$serverBase/storage/children/real.png'), isTrue);
    });

    test('8. normalizeJson correctly resolves image keys and leaves other fields untouched', () {
      final input = {
        'id': 101,
        'name': 'علي محمد',
        'email': 'ali@example.com',
        'status': 'active',
        'photo_url': '/storage/children/ali.png',
        'avatar': 'http://localhost:8000/storage/avatars/parent.jpg',
        'child_photo': 'null',
        'other_data': {
          'driver_avatar': 'storage/drivers/d1.png',
          'car_model': 'Hyundai H1',
          'price': 250.0,
        },
        'children_list': [
          {'id': 1, 'name': 'سارة', 'photo': '/storage/children/sara.png'},
          {'id': 2, 'name': 'أحمد', 'photo': 'undefined'},
        ],
      };

      final normalized = AppImageHelper.normalizeJson(input) as Map<String, dynamic>;

      // Non-image fields must remain exactly identical
      expect(normalized['id'], equals(101));
      expect(normalized['name'], equals('علي محمد'));
      expect(normalized['email'], equals('ali@example.com'));
      expect(normalized['status'], equals('active'));

      // Image fields must be resolved
      expect(normalized['photo_url'], equals('$serverBase/storage/children/ali.png'));
      expect(normalized['avatar'], equals('$serverBase/storage/avatars/parent.jpg'));
      expect(normalized['child_photo'], isNull); // 'null' string turned to real null

      // Nested map image fields
      final otherData = normalized['other_data'] as Map<String, dynamic>;
      expect(otherData['driver_avatar'], equals('$serverBase/storage/drivers/d1.png'));
      expect(otherData['car_model'], equals('Hyundai H1'));
      expect(otherData['price'], equals(250.0));

      // Nested list image fields
      final childrenList = normalized['children_list'] as List;
      final child1 = childrenList[0] as Map<String, dynamic>;
      expect(child1['photo'], equals('$serverBase/storage/children/sara.png'));
      final child2 = childrenList[1] as Map<String, dynamic>;
      expect(child2['photo'], isNull); // 'undefined' turned to real null
    });
  });
}
