import 'package:flutter_test/flutter_test.dart';
import 'package:kids_transport/features/parent/search/data/models/driver_search_model.dart';
import 'package:kids_transport/features/parent/search/data/models/subscription_request.dart';

void main() {
  group('DriverSearchModel parsing according to new Backend API Contract', () {
    test('يقرأ بيانات السائق والتسعير والمركبة والمناطق بشكل سليم', () {
      final json = {
        'id': 5,
        'driver_id': 5,
        'user_id': 20,
        'full_name': 'أحمد محمود',
        'phone_number': '0912345678',
        'gender': 'MALE',
        'rating': '4.8',
        'completed_trips': 120,
        'status': 'active',
        'available_seats': 3,
        'vehicle': {
          'brand': 'Toyota',
          'model': 'HiAce',
          'year': 2022,
          'color': 'White',
          'type': 'Van',
          'has_ac': 1,
          'capacity': 14,
          'plate_number': '12-34567',
        },
        'working_zones': [
          {'id': 1, 'name': 'حي الأندلس'},
          {'id': 2, 'name': 'سياحية'},
        ],
        'pricing': {
          'trip_price': 150.0,
          'total_price': '300 د.ل',
          'total_price_raw': 300.0,
          'working_days': 22,
          'distance_km': 12.5,
          'has_ac': 1,
          'price_per_km': 2.5,
          'children_count': 2,
          'breakdown': [
            {
              'child_id': 14,
              'child_name': 'عمر أحمد',
              'school_name': 'مدرسة النور',
              'distance_km': 6.0,
              'price_per_km': 2.5,
              'subscription_type': 'multi_day',
              'working_days': 22,
              'child_price': 150.0,
              'child_price_raw': 150,
              'subtotal': 150.0,
              'discount_percent': 0,
              'discount_amount': 0,
            },
            {
              'child_id': 15,
              'child_name': 'سارة أحمد',
              'school_name': 'مدرسة النور',
              'distance_km': 6.5,
              'price_per_km': 2.5,
              'subscription_type': 'multi_day',
              'working_days': 22,
              'child_price': 150.0,
              'child_price_raw': 150,
              'subtotal': 150.0,
              'discount_percent': 10.0,
              'discount_amount': 15.0,
            }
          ]
        }
      };

      final model = DriverSearchModel.fromJson(json);

      expect(model.driverId, 5);
      expect(model.userId, 20);
      expect(model.fullName, 'أحمد محمود');
      expect(model.gender, 'MALE');
      expect(model.rating, 4.8);
      expect(model.availableSeats, 3);
      expect(model.hasAc, isTrue);

      // Vehicle
      expect(model.vehicle.brand, 'Toyota');
      expect(model.vehicle.capacity, 14);
      expect(model.vehicle.capacityManual, 14);

      // Working zones
      expect(model.workingZones.length, 2);
      expect(model.serviceZones, ['حي الأندلس', 'سياحية']);

      // Pricing
      expect(model.pricing.tripPrice, 150.0);
      expect(model.pricing.totalPrice, 300.0);
      expect(model.pricing.totalPriceRaw, 300.0);
      expect(model.pricing.workingDays, 22);
      expect(model.pricing.distanceKm, 12.5);
      expect(model.pricing.hasAc, isTrue);
      expect(model.pricing.childrenCount, 2);

      // Breakdown
      expect(model.breakdown.length, 2);
      expect(model.breakdown[0].childId, 14);
      expect(model.breakdown[1].hasSiblingDiscount, isTrue);
      expect(model.hasSiblingDiscount, isTrue);
    });

    test('يتعامل بنجاح مع غياب حقول التسعير أو القيم الصفرية', () {
      final json = {
        'id': 10,
        'full_name': 'سائق تجريبي',
        'gender': 'male',
        'available_seats': '4',
        'pricing': {
          'total_price': 250,
          'has_ac': false,
          'price_per_km': '3.0',
          'children_count': 1,
        }
      };

      final model = DriverSearchModel.fromJson(json);
      expect(model.driverId, 10);
      expect(model.fullName, 'سائق تجريبي');
      expect(model.availableSeats, 4);
      expect(model.pricing.totalPrice, 250.0);
      expect(model.pricing.tripPrice, isNull);
      expect(model.pricing.workingDays, isNull);
      expect(model.pricing.distanceKm, isNull);
      expect(model.pricing.hasAc, isFalse);
      expect(model.breakdown, isEmpty);
      expect(model.hasSiblingDiscount, isFalse);
    });
  });

  group('SubscriptionRequest serialization according to POST /api/parent/requests Contract', () {
    test('يولد الـ JSON الدقيق المطابق لعقد الـ Backend بدون أي حقول زائدة', () {
      final request = SubscriptionRequest(
        driverId: 5,
        notes: 'ملاحظات إضافية بخصوص الوصول',
        children: [
          SubscriptionChildRequest(
            childId: 14,
            subscriptionType: 'multi_day',
            tripDirection: 'both',
            timing: 'MORNING',
            startDate: '2026-09-10',
            endDate: '2026-10-10',
          ),
          SubscriptionChildRequest(
            childId: 15,
            subscriptionType: 'single_day',
            tripDirection: 'go',
            timing: 'MORNING',
            startDate: '2026-09-15',
            endDate: '2026-09-15', // Should be omitted for single_day
          ),
        ],
      );

      final json = request.toJson();

      // Check top-level keys
      expect(json.keys.toSet(), {'driver_id', 'children', 'notes'});
      expect(json['driver_id'], 5);
      expect(json['notes'], 'ملاحظات إضافية بخصوص الوصول');

      // Check children list
      final childrenList = json['children'] as List<dynamic>;
      expect(childrenList.length, 2);

      // Child 1 (multi_day)
      final child1 = childrenList[0] as Map<String, dynamic>;
      expect(child1, {
        'child_id': 14,
        'subscription_type': 'multi_day',
        'trip_direction': 'both',
        'timing': 'MORNING',
        'start_date': '2026-09-10',
        'end_date': '2026-10-10',
      });

      // Child 2 (single_day) — end_date must NOT be present
      final child2 = childrenList[1] as Map<String, dynamic>;
      expect(child2, {
        'child_id': 15,
        'subscription_type': 'single_day',
        'trip_direction': 'go',
        'timing': 'MORNING',
        'start_date': '2026-09-15',
      });
      expect(child2.containsKey('end_date'), isFalse);

      // Ensure NO legacy keys exist in payload
      for (final c in childrenList) {
        final map = c as Map<String, dynamic>;
        expect(map.containsKey('parent_id'), isFalse);
        expect(map.containsKey('school_id'), isFalse);
        expect(map.containsKey('pickup_address_id'), isFalse);
        expect(map.containsKey('dropoff_address_id'), isFalse);
        expect(map.containsKey('price_per_child'), isFalse);
        expect(map.containsKey('child_notes'), isFalse);
      }
    });

    test('يتجاهل الملاحظات الفارغة أو الخالية من النص', () {
      final req1 = SubscriptionRequest(
        driverId: 8,
        notes: '',
        children: [
          SubscriptionChildRequest(
            childId: 10,
            subscriptionType: 'multi_day',
            tripDirection: 'return',
            timing: 'EVENING',
            startDate: '2026-09-01',
            endDate: '2026-09-30',
          )
        ],
      );

      final json1 = req1.toJson();
      expect(json1.containsKey('notes'), isFalse);

      final req2 = SubscriptionRequest(
        driverId: 8,
        notes: null,
        children: [
          SubscriptionChildRequest(
            childId: 10,
            subscriptionType: 'single_day',
            tripDirection: 'go',
            timing: 'MORNING',
            startDate: '2026-09-01',
          )
        ],
      );

      final json2 = req2.toJson();
      expect(json2.containsKey('notes'), isFalse);
    });
  });
}
