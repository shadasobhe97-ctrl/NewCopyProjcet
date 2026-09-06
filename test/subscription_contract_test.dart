import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kids_transport/core/utils/subscription_enums.dart';
import 'package:kids_transport/features/driver/requests/data/datasources/driver_requests_remote_data_source.dart';
import 'package:kids_transport/features/driver/requests/data/models/driver_request_model.dart';
import 'package:kids_transport/features/parent/search/data/models/subscription_request.dart';
import 'package:kids_transport/features/parent/subscriptions/data/models/request_model.dart';

/// استجابة حقيقية من الباك (طلب 124) بمفاتيح pickup_location / dropoff_location
const _requestJson = '''
{
  "id": 124,
  "status": "pending",
  "total_price": 650,
  "notes": "يرجى التواصل مع ولي الأمر قبل الانطلاق بـ 10 دقائق.",
  "driver": { "id": 189, "name": "محمد مسعود الجبالي", "phone": "0923181690", "photo": null },
  "children": [
    {
      "id": 144,
      "name": "آيلا عبدالعزيز محمد",
      "photo": null,
      "details": {
        "subscription_type": "multi_day",
        "trip_direction": "both",
        "timing": "MORNING",
        "start_date": "2026-08-27",
        "end_date": "2026-09-30",
        "working_days_count": 25,
        "distance_km": 0,
        "trip_price": 0,
        "price_per_child": 350
      },
      "pickup_location": {
        "id": 59, "name": "منزلي", "address": "عنوان غير متوفر",
        "latitude": 32.81510148, "longitude": 13.12894439
      },
      "dropoff_location": {
        "id": 4, "name": "مدرسة النور الابتدائية",
        "address": "النوفليين - بجانب المستشفى المركزي",
        "latitude": 32.899, "longitude": 13.205
      }
    },
    {
      "id": 145,
      "name": "لين عبدالعزيز محمد",
      "photo": null,
      "details": {
        "subscription_type": "single_day",
        "trip_direction": "return",
        "timing": "EVENING",
        "start_date": "2026-08-27",
        "end_date": "2026-08-27",
        "working_days_count": 1,
        "distance_km": 0,
        "trip_price": 0,
        "price_per_child": 300
      },
      "pickup_location": {
        "id": 59, "name": "منزلي", "address": "عنوان غير متوفر",
        "latitude": 32.81510148, "longitude": 13.12894439
      },
      "dropoff_location": {
        "id": 6, "name": "مدرسة الرواد الأهلية",
        "address": "سوق الجمعة - بالقرب من دوار قاطوشة",
        "latitude": 32.876, "longitude": 13.248
      }
    }
  ],
  "created_at": "2026-08-26T21:09:24+02:00",
  "updated_at": null
}
''';

/// نفس الطلب لكن بالمفاتيح البديلة Home / School
const _requestJsonHomeSchool = '''
{
  "id": 124,
  "status": "pending",
  "total_price": 650,
  "notes": null,
  "driver": { "id": 189, "name": "محمد مسعود الجبالي", "phone": "0923181690" },
  "children": [
    {
      "id": 144,
      "name": "آيلا عبدالعزيز محمد",
      "details": {
        "subscription_type": "multi_day", "trip_direction": "both", "timing": "MORNING",
        "start_date": "2026-08-27", "end_date": "2026-09-30",
        "working_days_count": 25, "distance_km": 0, "trip_price": 0, "price_per_child": 350
      },
      "Home": { "id": 59, "name": "منزلي", "address": "عنوان غير متوفر", "latitude": 32.8, "longitude": 13.1 },
      "School": { "id": 4, "name": "مدرسة النور الابتدائية", "address": "النوفليين", "latitude": 32.899, "longitude": 13.205 }
    }
  ],
  "created_at": "2026-08-26T21:09:24+02:00"
}
''';

/// سجل قديم ببيانات ناقصة + قيم اتجاه مخالفة للعقد
const _legacyJson = '''
{
  "id": 109,
  "status": "pending",
  "total_price": 650,
  "children": [
    {
      "id": 144, "name": "آيلا",
      "details": {
        "subscription_type": null, "trip_direction": "two_way", "timing": "BOTH",
        "start_date": null, "end_date": null, "working_days_count": 1, "price_per_child": 1
      }
    },
    {
      "id": 145, "name": "لين",
      "details": {
        "subscription_type": "single_day", "trip_direction": "one_way_evening", "timing": "BOTH",
        "start_date": "2026-08-27", "end_date": "2026-08-27",
        "working_days_count": 1, "price_per_child": 300
      }
    }
  ]
}
''';

void main() {
  group('نموذج ولي الأمر — RequestModel', () {
    final model =
        RequestModel.fromJson(jsonDecode(_requestJson) as Map<String, dynamic>);

    test('يقرأ الحقول العامة والسعر الإجمالي', () {
      expect(model.id, 124);
      expect(model.status, 'pending');
      expect(model.totalAmount, 650);
      expect(model.formattedPrice, '650 د.ل');
      expect(model.childrenCount, 2);
      expect(model.driver.name, 'محمد مسعود الجبالي');
      expect(model.notes, contains('يرجى التواصل'));
    });

    test('كل طفل يحمل تفاصيله الخاصة لا تفاصيل الطفل الأول', () {
      final ayla = model.children[0];
      final leen = model.children[1];

      expect(ayla.subscription.type, 'multi_day');
      expect(ayla.subscription.tripType, 'both');
      expect(ayla.subscription.timing, 'MORNING');
      expect(ayla.subscription.workingDaysCount, 25);
      expect(ayla.price, 350);

      expect(leen.subscription.type, 'single_day');
      expect(leen.subscription.tripType, 'return');
      expect(leen.subscription.timing, 'EVENING');
      expect(leen.subscription.workingDaysCount, 1);
      expect(leen.price, 300);
    });

    test('التسميات العربية بلا شهري أو أسبوعي', () {
      expect(model.children[0].subscription.typeDisplayLabel, 'عدة أيام');
      expect(model.children[1].subscription.typeDisplayLabel, 'يوم واحد');
      expect(model.children[0].subscription.tripTypeDisplayLabel, 'ذهاب وعودة');
      expect(model.children[1].subscription.tripTypeDisplayLabel, 'عودة فقط');
      expect(model.children[0].subscription.timingDisplayLabel, 'صباحاً');
      expect(model.children[1].subscription.timingDisplayLabel, 'مساءً');

      for (final c in model.children) {
        expect(c.subscription.typeDisplayLabel, isNot(contains('شهري')));
        expect(c.subscription.typeDisplayLabel, isNot(contains('أسبوعي')));
      }
    });

    test('اسم الموقع يعرض والعنوان البديل يخفى', () {
      final pickup = model.children[0].pickupLocation!;
      expect(pickup.displayName, 'منزلي');
      expect(pickup.hasRealAddress, isFalse);
      expect(pickup.displayAddress, isNull);
      expect(pickup.hasValidCoordinates, isTrue);
    });

    test('اسم المدرسة يختلف بين الطفلين', () {
      expect(model.children[0].schoolName, 'مدرسة النور الابتدائية');
      expect(model.children[1].schoolName, 'مدرسة الرواد الأهلية');
      expect(model.children[0].dropoffLocation!.displayAddress,
          'النوفليين - بجانب المستشفى المركزي');
    });

    test('يقرأ trip_price و distance_km', () {
      expect(model.children[0].subscription.tripPrice, 0);
      expect(model.children[0].subscription.distanceKm, 0);
    });

    test('يدعم المفاتيح البديلة Home و School', () {
      final alt = RequestModel.fromJson(
          jsonDecode(_requestJsonHomeSchool) as Map<String, dynamic>);
      expect(alt.children[0].pickupLocation!.displayName, 'منزلي');
      expect(alt.children[0].schoolName, 'مدرسة النور الابتدائية');
      expect(alt.children[0].dropoffLocation!.displayAddress, 'النوفليين');
    });

    test('السجلات القديمة لا تنهار ولا تعرض شهري', () {
      final legacy =
          RequestModel.fromJson(jsonDecode(_legacyJson) as Map<String, dynamic>);
      expect(legacy.children[0].subscription.typeDisplayLabel, 'غير متوفر');
      expect(legacy.children[0].subscription.tripTypeDisplayLabel, 'ذهاب وعودة');
      expect(legacy.children[1].subscription.tripTypeDisplayLabel, 'عودة فقط');
    });
  });

  group('نموذج السائق — DriverRequestModel', () {
    final model = DriverRequestModel.fromJson(
        jsonDecode(_requestJson) as Map<String, dynamic>);

    test('يقرأ الطلب والسعر الإجمالي وقائمة الأطفال', () {
      expect(model.id, 124);
      expect(model.totalPrice, '650');
      expect(model.children.length, 2);
    });

    test('كل طفل بتفاصيله وسعره ومدرسته', () {
      final ayla = model.children[0];
      final leen = model.children[1];

      expect(ayla.details.typeLabel, 'عدة أيام');
      expect(ayla.details.directionLabel, 'ذهاب وعودة');
      expect(ayla.details.timingLabel, 'صباحاً');
      expect(ayla.priceLabel, '350 د.ل');
      expect(ayla.dropoffLocation!.displayName, 'مدرسة النور الابتدائية');

      expect(leen.details.typeLabel, 'يوم واحد');
      expect(leen.details.directionLabel, 'عودة فقط');
      expect(leen.details.timingLabel, 'مساءً');
      expect(leen.priceLabel, '300 د.ل');
      expect(leen.dropoffLocation!.displayName, 'مدرسة الرواد الأهلية');
    });

    test('يكتشف اختلاف إعدادات الأطفال', () {
      expect(model.hasMixedChildDetails, isTrue);
    });

    test('العنوان البديل مخفي وسعر الرحلة مقروء', () {
      expect(model.children[0].pickupLocation!.displayName, 'منزلي');
      expect(model.children[0].pickupLocation!.displayAddress, isNull);
      expect(model.children[0].details.tripPrice, 0);
    });

    test('لا يعرض شهري حتى لو غابت التفاصيل', () {
      final legacy = DriverRequestModel.fromJson(
          jsonDecode(_legacyJson) as Map<String, dynamic>);
      expect(legacy.subscriptionTypeDisplayLabel, isNot(contains('شهري')));
      for (final c in legacy.children) {
        expect(c.details.typeLabel, anyOf('عدة أيام', 'يوم واحد'));
      }
    });
  });

  group('جسم الإرسال — SubscriptionRequest', () {
    test('كل طفل يرسل بإعداداته الخاصة ومطابقا للعقد', () {
      final req = SubscriptionRequest(
        driverId: 189,
        notes: 'يرجى التواصل مع ولي الأمر قبل الانطلاق بـ 10 دقائق.',
        children: [
          SubscriptionChildRequest(
            childId: 144,
            schoolId: 1,
            subscriptionType: 'multi_day',
            tripDirection: 'both',
            timing: 'MORNING',
            startDate: '2026-08-27',
            endDate: '2026-09-30',
            pickupAddressId: 37,
            dropoffAddressId: 4,
            pricePerChild: 350.00,
          ),
          SubscriptionChildRequest(
            childId: 145,
            schoolId: 1,
            subscriptionType: 'single_day',
            tripDirection: 'return',
            timing: 'EVENING',
            startDate: '2026-08-27',
            pickupAddressId: 37,
            dropoffAddressId: 4,
            pricePerChild: 300.00,
          ),
        ],
      );

      final json = req.toJson();
      expect(json['driver_id'], 189);
      expect(json['notes'], contains('يرجى التواصل'));

      final kids = json['children'] as List;
      expect(kids.length, 2);

      expect(kids[0], {
        'child_id': 144,
        'subscription_type': 'multi_day',
        'trip_direction': 'both',
        'timing': 'MORNING',
        'start_date': '2026-08-27',
        'end_date': '2026-09-30',
      });

      expect((kids[1] as Map)['subscription_type'], 'single_day');
      expect((kids[1] as Map)['trip_direction'], 'return');
      expect((kids[1] as Map)['timing'], 'EVENING');
      expect((kids[1] as Map).containsKey('end_date'), isFalse);
    });

    test('يطبع القيم القديمة قبل الإرسال', () {
      final child = SubscriptionChildRequest(
        childId: 1,
        schoolId: 1,
        subscriptionType: 'monthly',
        tripDirection: 'two_way',
        timing: 'afternoon',
        startDate: '2026-08-27',
        endDate: '2026-09-30',
        pickupAddressId: 37,
        dropoffAddressId: 4,
        pricePerChild: 350,
      );

      expect(child.subscriptionType, 'multi_day');
      expect(child.tripDirection, 'both');
      expect(child.timing, 'EVENING');

      final daily = SubscriptionChildRequest(
        childId: 2,
        schoolId: 1,
        subscriptionType: 'daily',
        tripDirection: 'one_way_evening',
        timing: 'MORNING',
        startDate: '2026-08-27',
        endDate: '2026-09-30',
        pickupAddressId: 37,
        dropoffAddressId: 4,
        pricePerChild: 300,
      );

      expect(daily.subscriptionType, 'single_day');
      expect(daily.tripDirection, 'return');
      expect(daily.endDate, isNull);
    });
  });

  group('SubscriptionEnums', () {
    test('لا ينتج شهري أو أسبوعي لأي مدخل', () {
      for (final v in [
        'monthly',
        'weekly',
        'multi_day',
        'single_day',
        'daily',
        'days',
        '',
        'قيمة غريبة'
      ]) {
        final label = SubscriptionEnums.typeLabel(v);
        expect(label, anyOf('يوم واحد', 'عدة أيام'), reason: 'input: $v');
      }
    });

    test('يطبع الاتجاهات والفترات', () {
      expect(SubscriptionEnums.normalizeDirection('two_way'), 'both');
      expect(SubscriptionEnums.normalizeDirection('one_way_evening'), 'return');
      expect(SubscriptionEnums.normalizeDirection('one_way_to_school'), 'go');
      expect(SubscriptionEnums.normalizeTiming('afternoon'), 'EVENING');
      expect(SubscriptionEnums.normalizeTiming('MORNING'), 'MORNING');
    });
  });

  group('ترقيم قائمة طلبات السائق', () {
    // شكل الاستجابة الحقيقي: الترقيم داخل meta والروابط داخل links
    const listJson = '''
{
  "data": [
    { "id": 124, "status": "pending", "total_price": 650, "children": [] },
    { "id": 116, "status": "pending", "total_price": 650, "children": [] }
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
      expect(page.data.first.id, 124);
      expect(page.currentPage, 1);
      expect(page.lastPage, 3);
      expect(page.perPage, 15);
      expect(page.hasMore, isTrue); // كان دائماً false قبل الإصلاح
      expect(page.nextPageUrl, contains('page=2'));
    });

    test('صفحة واحدة فقط لا تطلب المزيد', () {
      final single = DriverRequestsRemoteDataSource.parsePaginated({
        'data': [
          {'id': 1, 'status': 'pending', 'total_price': 10, 'children': []}
        ],
        'links': {'next': null},
        'meta': {'current_page': 1, 'last_page': 1, 'per_page': 15},
        'status': true,
      });

      expect(single.hasMore, isFalse);
      expect(single.nextPageUrl, isNull);
    });

    test('يرمي خطأ برسالة الخادم عند status: false', () {
      expect(
        () => DriverRequestsRemoteDataSource.parsePaginated({
          'status': false,
          'message': 'لم يتم العثور على ملفك الشخصي',
        }),
        throwsA(predicate((e) =>
            e.toString().contains('لم يتم العثور على ملفك الشخصي'))),
      );
    });

    test('يتحمّل الشكل القديم بترقيم في الجذر', () {
      final legacy = DriverRequestsRemoteDataSource.parsePaginated({
        'data': [
          {'id': 9, 'status': 'pending', 'total_price': 5, 'children': []}
        ],
        'current_page': 2,
        'last_page': 4,
        'per_page': 10,
        'next_page_url': 'https://x/api/driver/requests?page=3',
      });

      expect(legacy.currentPage, 2);
      expect(legacy.lastPage, 4);
      expect(legacy.hasMore, isTrue);
    });
  });

  group('مسار تفاصيل طلب السائق — GET /api/driver/requests/{id}', () {
    // استجابة حقيقية (طلب 127) بشكل مختلف تماماً عن القائمة
    const detailJson = '''
{
  "id": 127,
  "status": { "value": "pending" },
  "notes": "يرجى التواصل مع ولي الأمر قبل الانطلاق بـ 10 دقائق.",
  "total_amount": 598,
  "currency": "د.ل",
  "children_count": 1,
  "parent": {
    "id": 37, "name": "أم محمد عبدالعزيز", "phone": "0922225533",
    "email": "alasalem2502@gmail.com", "avatar": null
  },
  "children": [
    {
      "id": 28, "name": "محمد عبدالعزيز محمد", "gender": "male", "age": 7,
      "grade": 2, "photo_url": null,
      "notes": { "child_notes": "لديه حساسية من الفراولة" },
      "pricing": { "trip_price": 161, "total_price": 322 },
      "subscription_period": {
        "start_date": "2026-08-27", "end_date": "2026-09-30", "working_days_count": 25
      },
      "trip_details": {
        "subscription_type": "multi_day", "trip_direction": "both", "timing": "MORNING"
      },
      "school": {
        "id": 1, "name": "مدرسة الجيل الجديد الدولية",
        "address": "حي الأندلس - بالقرب من جامع الأندلس", "lat": 32.892, "lng": 13.168
      },
      "home": { "address": "منزلي", "lat": 32.81510148, "lng": 13.12894439 }
    },
    {
      "id": 145, "name": "لين عبدالعزيز محمد", "gender": "female", "age": 11,
      "grade": 0, "photo_url": null,
      "notes": { "child_notes": null },
      "pricing": { "trip_price": 138, "total_price": 276 },
      "subscription_period": {
        "start_date": "2026-08-27", "end_date": "2026-08-27", "working_days_count": 1
      },
      "trip_details": {
        "subscription_type": "single_day", "trip_direction": "return", "timing": "EVENING"
      },
      "school": {
        "id": 6, "name": "مدرسة الرواد الأهلية",
        "address": "سوق الجمعة - بالقرب من دوار قاطوشة", "lat": 32.876, "lng": 13.248
      },
      "home": { "address": "منزلي", "lat": 32.81510148, "lng": 13.12894439 }
    }
  ],
  "created_at": "2026-08-26T22:53:09+02:00",
  "created_at_formatted": "2026-08-26 22:53"
}
''';

    final model = DriverRequestModel.fromJson(
        jsonDecode(detailJson) as Map<String, dynamic>);

    test('يقرأ status ككائن و total_amount والعملة', () {
      expect(model.id, 127);
      expect(model.status, 'pending');
      expect(model.statusDisplayLabel, 'معلق');
      expect(model.totalPrice, '598');
      expect(model.currency, 'د.ل');
      expect(model.createdAtFormatted, '2026-08-26 22:53');
    });

    test('يقرأ بيانات ولي الأمر', () {
      expect(model.parent.name, 'أم محمد عبدالعزيز');
      expect(model.parent.phone, '0922225533');
      expect(model.parent.email, 'alasalem2502@gmail.com');
    });

    test('عدد الأطفال يتبع القائمة الفعلية لا children_count الخاطئ', () {
      expect(model.children.length, 2);
      expect(model.childrenCount, 2); // الخادم أرسل 1 وهو غلط
    });

    test('يقرأ trip_details و subscription_period و pricing لكل طفل', () {
      final mohamed = model.children[0];
      final leen = model.children[1];

      expect(mohamed.details.typeLabel, 'عدة أيام');
      expect(mohamed.details.directionLabel, 'ذهاب وعودة');
      expect(mohamed.details.timingLabel, 'صباحاً');
      expect(mohamed.details.startDate, '2026-08-27');
      expect(mohamed.details.endDate, '2026-09-30');
      expect(mohamed.details.workingDaysCount, 25);
      expect(mohamed.details.tripPrice, 161);
      expect(mohamed.price, 322);
      expect(mohamed.age, 7);
      expect(mohamed.childNotes, 'لديه حساسية من الفراولة');

      expect(leen.details.typeLabel, 'يوم واحد');
      expect(leen.details.directionLabel, 'عودة فقط');
      expect(leen.details.timingLabel, 'مساءً');
      expect(leen.details.workingDaysCount, 1);
      expect(leen.details.tripPrice, 138);
      expect(leen.price, 276);
      expect(leen.age, 11);
      expect(leen.childNotes, isNull);
    });

    test('يقرأ school و home بمفاتيح lat/lng', () {
      final school = model.children[0].dropoffLocation!;
      expect(school.displayName, 'مدرسة الجيل الجديد الدولية');
      expect(school.displayAddress, 'حي الأندلس - بالقرب من جامع الأندلس');
      expect(school.latitude, 32.892);
      expect(school.longitude, 13.168);

      final home = model.children[0].pickupLocation!;
      expect(home.displayName, 'منزلي');
      expect(home.displayAddress, isNull); // لا يتكرر تحت الاسم
      expect(home.hasCoordinates, isTrue);

      // مدرسة مختلفة للطفل الثاني
      expect(model.children[1].dropoffLocation!.displayName,
          'مدرسة الرواد الأهلية');
    });

    test('يكتشف اختلاف إعدادات الأطفال ولا يعرض شهري', () {
      expect(model.hasMixedChildDetails, isTrue);
      for (final c in model.children) {
        expect(c.details.typeLabel, isNot(contains('شهري')));
      }
    });
  });
}
