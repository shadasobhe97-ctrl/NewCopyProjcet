import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kids_transport/features/driver/requests/data/datasources/driver_requests_remote_data_source.dart';
import 'package:kids_transport/features/driver/requests/data/models/driver_request_model.dart';
import 'package:kids_transport/features/driver/subscriptions/data/models/driver_subscription_model.dart';

/// استجابة العقد الجديد للطلب الموحد / الاشتراك الموحد (مع طفلين)
const _unifiedResponseJson = '''
{
  "id": 105,
  "status": "active",
  "status_label": "ساري ومفعل",

  "parent": {
    "id": 20,
    "name": "المختار الوالد",
    "phone": "0921111111",
    "alternative_phone": null,
    "gender": "male",
    "photo_url": null
  },

  "subscription": {
    "type": "monthly",
    "type_label": "اشتراك شهري",
    "direction": "both",
    "direction_label": "ذهاب وإياب",
    "start_date": "2026-09-10",
    "end_date": "2026-10-10",
    "working_days_count": 22
  },

  "home_address": {
    "id": 12,
    "label": "المنزل",
    "lat": 32.8872,
    "lng": 13.1913
  },

  "children_count": 2,

  "pricing": {
    "total_price": 1000.0,
    "discount_amount": 100.0,
    "total_amount_after_discount": 900.0,
    "platform_commission_total": 90.0,
    "driver_net_total": 810.0
  },

  "children": [
    {
      "child_id": 1,
      "name": "عمر المختار",
      "photo_url": null,
      "age": 10,
      "gender": "male",
      "grade": "الخامس",
      "grade_label": "الصف الخامس",

      "school": {
        "id": 5,
        "name": "مدرسة الأجيال",
        "lat": 32.8900,
        "lng": 13.1950
      },

      "timing": null,
      "distance_km": 5.2,
      "medical_notes": "لا يوجد",

      "pricing": {
        "price_before_discount": 500.0,
        "discount_percentage": 10.0,
        "discount_amount": 50.0,
        "price_after_discount": 450.0,
        "platform_commission_amount": 45.0,
        "driver_net_price": 405.0
      },

      "active_subscription": {
        "id": 500,
        "status": "active",
        "status_label": "ساري ومفعل",
        "route_id": 8,
        "pickup_time": "06:30:00",
        "dropoff_time": "14:00:00"
      }
    },
    {
      "child_id": 2,
      "name": "فاطمة المختار",
      "photo_url": "https://example.com/photo.jpg",
      "age": 8,
      "gender": "female",
      "grade": 3,
      "grade_label": "الصف الثالث",

      "school": {
        "id": 6,
        "name": "مدرسة الرواد",
        "lat": 32.8950,
        "lng": 13.1980
      },

      "timing": "MORNING",
      "distance_km": 4.0,
      "medical_notes": "حساسية من المكسرات",

      "pricing": {
        "price_before_discount": 500.0,
        "discount_percentage": 10.0,
        "discount_amount": 50.0,
        "price_after_discount": 450.0,
        "platform_commission_amount": 45.0,
        "driver_net_price": 405.0
      },

      "active_subscription": {
        "id": 501,
        "status": "active",
        "status_label": "ساري ومفعل",
        "route_id": 8,
        "pickup_time": "06:40:00",
        "dropoff_time": "14:10:00"
      }
    }
  ],

  "notes": "الرجاء الانتباه للأطفال عند النزول",
  "created_at": "2026-09-08T10:00:00Z",
  "updated_at": "2026-09-08T11:05:00Z"
}
''';

/// استجابة طلب معلق لطفل واحد (بدون active_subscription)
const _singlePendingRequestJson = '''
{
  "id": 108,
  "status": "pending",
  "status_label": "قيد الانتظار",

  "parent": {
    "id": 25,
    "name": "سالم الفيتوري",
    "phone": "0912223344",
    "alternative_phone": "0923334455",
    "gender": "male",
    "photo_url": null
  },

  "subscription": {
    "type": "single_day",
    "type_label": "اشتراك يوم واحد",
    "direction": "go",
    "direction_label": "ذهاب فقط",
    "start_date": "2026-09-12",
    "end_date": "2026-09-12",
    "working_days_count": 1
  },

  "home_address": {
    "id": 14,
    "label": "منزل حي الأندلس",
    "lat": 32.8800,
    "lng": 13.1800
  },

  "children_count": 1,

  "pricing": {
    "total_price": 40.0,
    "discount_amount": 0.0,
    "total_amount_after_discount": 40.0,
    "platform_commission_total": 4.0,
    "driver_net_total": 36.0
  },

  "children": [
    {
      "child_id": 10,
      "name": "أيوب سالم",
      "photo_url": null,
      "age": 6,
      "gender": "male",
      "grade": 1,
      "grade_label": "الصف الأول",

      "school": {
        "id": 2,
        "name": "مدرسة الأمل",
        "lat": 32.8850,
        "lng": 13.1850
      },

      "timing": "MORNING",
      "distance_km": 2.5,
      "medical_notes": null,

      "pricing": {
        "price_before_discount": 40.0,
        "discount_percentage": 0.0,
        "discount_amount": 0.0,
        "price_after_discount": 40.0,
        "platform_commission_amount": 4.0,
        "driver_net_price": 36.0
      }
    }
  ],

  "notes": "ملاحظات إضافية",
  "created_at": "2026-09-09T08:00:00Z"
}
''';

void main() {
  group('نموذج طلب السائق الموحد — DriverRequestModel', () {
    test('يقرأ الاشتراك الموحد مع طفلين وبيانات التسعير العامة والخاصة', () {
      final model = DriverRequestModel.fromJson(
          jsonDecode(_unifiedResponseJson) as Map<String, dynamic>);

      // 1. هوية الطلب في المستوى الأعلى
      expect(model.id, 105);
      expect(model.status, 'active');
      expect(model.statusLabel, 'ساري ومفعل');
      expect(model.statusDisplayLabel, 'ساري ومفعل');

      // 2. ولي الأمر في المستوى الأعلى
      expect(model.parent.id, 20);
      expect(model.parent.name, 'المختار الوالد');
      expect(model.parent.phone, '0921111111');
      expect(model.parent.alternativePhone, isNull);

      // 3. بيانات الاشتراك الموحد
      expect(model.subscription.startDate, '2026-09-10');
      expect(model.subscription.endDate, '2026-10-10');
      expect(model.subscription.workingDaysCount, 22);
      expect(model.subscription.direction, 'both');
      expect(model.subscription.directionDisplayLabel, 'ذهاب وعودة');

      // 4. عدم عرض "اشتراك شهري" في الواجهة وتحويلها إلى "عدة أيام"
      expect(model.subscription.typeDisplayLabel, 'عدة أيام');
      expect(model.subscription.typeDisplayLabel, isNot(contains('شهري')));

      // 5. عنوان المنزل في المستوى الأعلى
      expect(model.homeAddress?.id, 12);
      expect(model.homeAddress?.displayName, 'المنزل');
      expect(model.homeAddress?.lat, 32.8872);
      expect(model.homeAddress?.lng, 13.1913);

      // 6. التسعير المالي الموحد على مستوى الاشتراك
      expect(model.pricing?.totalPrice, 1000.0);
      expect(model.pricing?.discountAmount, 100.0);
      expect(model.pricing?.totalAmountAfterDiscount, 900.0);
      expect(model.pricing?.platformCommissionTotal, 90.0);
      expect(model.pricing?.driverNetTotal, 810.0);

      // 7. الأطفال داخل children[]
      expect(model.children.length, 2);
      expect(model.childrenCount, 2);

      // الطفل الأول
      final child1 = model.children[0];
      expect(child1.childId, 1);
      expect(child1.name, 'عمر المختار');
      expect(child1.age, 10);
      expect(child1.displayGrade, 'الصف الخامس');
      expect(child1.school?.name, 'مدرسة الأجيال');
      expect(child1.timing, isNull);
      expect(child1.distanceKm, 5.2);
      expect(child1.pricing?.priceAfterDiscount, 450.0);
      expect(child1.pricing?.driverNetPrice, 405.0);

      // active_subscription داخل الطفل
      expect(child1.activeSubscription, isNotNull);
      expect(child1.activeSubscription?.id, 500);
      expect(child1.activeSubscription?.routeId, 8);
      expect(child1.activeSubscription?.pickupTime, '06:30:00');
      expect(child1.activeSubscription?.dropoffTime, '14:00:00');

      // الطفل الثاني
      final child2 = model.children[1];
      expect(child2.childId, 2);
      expect(child2.name, 'فاطمة المختار');
      expect(child2.school?.name, 'مدرسة الرواد');
      expect(child2.activeSubscription?.id, 501);

      // التأكد من أن Subscription ID (105) مستقل عن active_subscription.id (500)
      expect(model.id, isNot(child1.activeSubscription?.id));
    });

    test('يقرأ الطلب المعلق لطفل واحد بدون active_subscription دون حدوث crash', () {
      final model = DriverRequestModel.fromJson(
          jsonDecode(_singlePendingRequestJson) as Map<String, dynamic>);

      expect(model.id, 108);
      expect(model.status, 'pending');
      expect(model.statusDisplayLabel, 'قيد الانتظار');
      expect(model.children.length, 1);
      expect(model.children[0].childId, 10);
      expect(model.children[0].name, 'أيوب سالم');
      expect(model.children[0].activeSubscription, isNull);
      expect(model.subscription.typeDisplayLabel, 'يوم واحد');
      expect(model.subscription.directionDisplayLabel, 'ذهاب فقط');
      expect(model.parent.alternativePhone, '0923334455');
    });
  });

  group('نموذج الاشتراك الموحد للسائق — DriverSubscriptionModel', () {
    test('يقرأ الاشتراك الموحد كنموذج مستقل باستخدام النماذج المتداخلة المشتركة', () {
      final sub = DriverSubscriptionModel.fromJson(
          jsonDecode(_unifiedResponseJson) as Map<String, dynamic>);

      expect(sub.id, 105);
      expect(sub.parent.name, 'المختار الوالد');
      expect(sub.children.length, 2);
      expect(sub.children[0].activeSubscription?.id, 500);
      expect(sub.children[1].activeSubscription?.id, 501);
      expect(sub.typeDisplayLabel, 'عدة أيام');
      expect(sub.typeDisplayLabel, isNot(contains('شهري')));
      expect(sub.pricing?.formattedDriverNet, '810 د.ل');
    });
  });

  group('ترقيم قائمة طلبات السائق', () {
    const listJson = '''
{
  "data": [
    { "id": 105, "status": "active", "children_count": 2, "children": [] },
    { "id": 108, "status": "pending", "children_count": 1, "children": [] }
  ],
  "links": {
    "first": "https://x/api/driver/requests?page=1",
    "last": "https://x/api/driver/requests?page=3",
    "prev": null,
    "next": "https://x/api/driver/requests?page=2"
  },
  "meta": { "current_page": 1, "last_page": 3, "per_page": 15, "total": 40 },
  "status": true,
  "message": "تم جلب طلبات الاشتراك بنجاح"
}
''';

    test('يقرأ الترقيم من meta لا من جذر الاستجابة', () {
      final page = DriverRequestsRemoteDataSource.parsePaginated(
          jsonDecode(listJson) as Map<String, dynamic>);

      expect(page.data.length, 2);
      expect(page.data.first.id, 105);
      expect(page.currentPage, 1);
      expect(page.lastPage, 3);
      expect(page.perPage, 15);
      expect(page.hasMore, isTrue);
      expect(page.nextPageUrl, contains('page=2'));
    });
  });
}
