import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kids_transport/core/utils/subscription_enums.dart';
import 'package:kids_transport/features/driver/requests/data/datasources/driver_requests_remote_data_source.dart';
import 'package:kids_transport/features/driver/requests/data/models/driver_request_model.dart';
import 'package:kids_transport/features/parent/search/data/models/subscription_request.dart';
import 'package:kids_transport/features/parent/subscriptions/data/models/active_subscription_model.dart';
import 'package:kids_transport/features/parent/subscriptions/data/models/request_model.dart';

/// استجابة الباك الجديدة لعرض طلب الاشتراك لولي الأمر
const _parentRequestJson = '''
{
  "id": 105,
  "status": "pending",
  "status_label": "قيد الانتظار",
  "driver": {
    "id": 45,
    "name": "أحمد السائق",
    "phone": "0912345678",
    "alternative_phone": null,
    "gender": "male",
    "photo_url": "https://example.com/avatar.jpg",
    "vehicle": {
      "has_ac": true,
      "capacity": 4,
      "plate_number": "12345-6"
    }
  },
  "subscription": {
    "type": "multi_day",
    "type_label": "عدة أيام",
    "direction": "both",
    "direction_label": "ذهاب وعودة",
    "start_date": "2026-09-10",
    "end_date": "2026-09-30",
    "working_days_count": 15
  },
  "home_address": {
    "id": 12,
    "label": "المنزل - حي الأندلس",
    "lat": 32.8872,
    "lng": 13.1913
  },
  "children_count": 2,
  "pricing": {
    "total_price": 500.00,
    "discount_amount": 50.00,
    "total_amount_after_discount": 450.00
  },
  "children": [
    {
      "child_id": 5,
      "name": "سارة",
      "photo_url": null,
      "age": 8,
      "gender": "female",
      "grade": "3",
      "grade_label": "الصف الثالث",
      "school": {
        "id": 3,
        "name": "مدرسة الأمل الابتدائية",
        "lat": 32.8900,
        "lng": 13.1800
      },
      "timing": "morning",
      "distance_km": 4.5,
      "medical_notes": null,
      "pricing": {
        "price_before_discount": 250.00,
        "discount_percentage": 10.0,
        "discount_amount": 25.00,
        "price_after_discount": 225.00
      }
    },
    {
      "child_id": 8,
      "name": "علي",
      "photo_url": null,
      "age": 10,
      "gender": "male",
      "grade": "5",
      "grade_label": "الصف الخامس",
      "school": {
        "id": 4,
        "name": "مدرسة النور الإعدادية",
        "lat": 32.8950,
        "lng": 13.1850
      },
      "timing": "morning",
      "distance_km": 5.2,
      "medical_notes": "حساسية من الغبار",
      "pricing": {
        "price_before_discount": 250.00,
        "discount_percentage": 10.0,
        "discount_amount": 25.00,
        "price_after_discount": 225.00
      }
    }
  ],
  "notes": "يرجى الحضور في الوقت المحدد",
  "created_at": "2026-09-08T10:30:00Z"
}
''';

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
    final model = RequestModel.fromJson(
        jsonDecode(_parentRequestJson) as Map<String, dynamic>);

    test('يقرأ الحقول العامة والسائق وبيانات الاشتراك المشتركة', () {
      expect(model.id, 105);
      expect(model.status, 'pending');
      expect(model.statusDisplayLabel, 'قيد الانتظار');
      expect(model.childrenCount, 2);
      expect(model.driver.name, 'أحمد السائق');
      expect(model.driver.phone, '0912345678');
      expect(model.driver.vehicle?.hasAc, isTrue);
      expect(model.driver.vehicle?.plateNumber, '12345-6');
      expect(model.subscription.type, 'multi_day');
      expect(model.subscription.typeDisplayLabel, 'عدة أيام');
      expect(model.subscription.direction, 'both');
      expect(model.subscription.directionDisplayLabel, 'ذهاب وعودة');
      expect(model.subscription.workingDaysCount, 15);
      expect(model.homeAddress?.label, 'المنزل - حي الأندلس');
      expect(model.notes, contains('يرجى الحضور'));
    });

    test('يقرأ التسعير الإجمالي والخصم بالشكل المنسق', () {
      expect(model.pricing?.totalPrice, 500.0);
      expect(model.pricing?.discountAmount, 50.0);
      expect(model.pricing?.totalAmountAfterDiscount, 450.0);
      expect(model.pricing?.hasDiscount, isTrue);
      expect(model.formattedTotalPrice, '450 د.ل');
    });

    test('كل طفل يحمل تسعيره الخاص ومدرسته وبياناته', () {
      expect(model.children.length, 2);
      expect(model.childrenNames, 'سارة، علي');

      final sara = model.children[0];
      expect(sara.childId, 5);
      expect(sara.name, 'سارة');
      expect(sara.gender, 'female');
      expect(sara.isFemale, isTrue);
      expect(sara.gradeLabelDisplay, 'الصف الثالث');
      expect(sara.school.name, 'مدرسة الأمل الابتدائية');
      expect(sara.pricing?.priceBeforeDiscount, 250.0);
      expect(sara.pricing?.priceAfterDiscount, 225.0);
      expect(sara.pricing?.discountPercentage, 10.0);
      expect(sara.pricing?.hasDiscount, isTrue);

      final ali = model.children[1];
      expect(ali.childId, 8);
      expect(ali.name, 'علي');
      expect(ali.gender, 'male');
      expect(ali.isFemale, isFalse);
      expect(ali.gradeLabelDisplay, 'الصف الخامس');
      expect(ali.school.name, 'مدرسة النور الإعدادية');
      expect(ali.medicalNotes, 'حساسية من الغبار');
    });

    test('التسميات العربية بلا شهري أو أسبوعي', () {
      expect(model.subscription.typeDisplayLabel, isNot(contains('شهري')));
      expect(model.subscription.typeDisplayLabel, isNot(contains('أسبوعي')));
      expect(model.subscription.typeDisplayLabel, 'عدة أيام');
      expect(model.subscription.directionDisplayLabel, 'ذهاب وعودة');
    });

    test('يدعم تحويل النموذج إلى JSON واسترجاعه بدقة', () {
      final json = model.toJson();
      final restored = RequestModel.fromJson(json);
      expect(restored.id, model.id);
      expect(restored.children.length, model.children.length);
      expect(restored.formattedTotalPrice, model.formattedTotalPrice);
      expect(restored.children[0].name, 'سارة');
    });
  });

  group('نموذج الاشتراك النشط — ActiveSubscriptionModel', () {
    const activeJson = '''
{
  "active_subscription_id": 88,
  "status": "active",
  "status_label": "نشط",
  "driver": {
    "id": 45,
    "name": "أحمد السائق",
    "phone": "0912345678",
    "vehicle": {
      "has_ac": true,
      "plate_number": "12345-6"
    }
  },
  "subscription": {
    "type": "multi_day",
    "type_label": "عدة أيام",
    "direction": "both",
    "direction_label": "ذهاب وعودة",
    "start_date": "2026-09-10",
    "end_date": "2026-09-30",
    "working_days_count": 15
  },
  "home_address": {
    "id": 12,
    "label": "المنزل - حي الأندلس"
  },
  "child": {
    "child_id": 5,
    "name": "سارة",
    "school": {
      "name": "مدرسة الأمل الابتدائية"
    },
    "pricing": {
      "price_after_discount": 225.00
    }
  },
  "pickup_time": "07:30",
  "dropoff_time": "14:00",
  "created_at": "2026-09-08T10:30:00Z"
}
''';

    final model = ActiveSubscriptionModel.fromJson(
        jsonDecode(activeJson) as Map<String, dynamic>);

    test('يقرأ الحقول العامة والسائق والاشتراك', () {
      expect(model.id, 88);
      expect(model.status, 'active');
      expect(model.statusDisplayLabel, 'نشط');
      expect(model.driver.name, 'أحمد السائق');
      expect(model.subscription.typeDisplayLabel, 'عدة أيام');
      expect(model.pickupTime, '07:30');
      expect(model.dropoffTime, '14:00');
    });

    test('يقرأ الطفل والتسعير المنسق', () {
      expect(model.children.length, 1);
      expect(model.firstChild?.name, 'سارة');
      expect(model.formattedPrice, '225 دينار');
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

    test('يدعم المفاتيح البديلة Home و School في نموذج السائق', () {
      final alt = DriverRequestModel.fromJson(
          jsonDecode(_requestJsonHomeSchool) as Map<String, dynamic>);
      expect(alt.children[0].pickupLocation!.displayName, 'منزلي');
      expect(alt.children[0].dropoffLocation!.displayName,
          'مدرسة النور الابتدائية');
      expect(alt.children[0].dropoffLocation!.displayAddress, 'النوفليين');
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
        subscriptionType: 'multi_day',
        tripDirection: 'both',
        startDate: '2026-08-27',
        endDate: '2026-09-30',
        homeAddressId: 37,
        notes: 'يرجى التواصل مع ولي الأمر قبل الانطلاق بـ 10 دقائق.',
        children: [
          SubscriptionChildRequest(childId: 144),
          SubscriptionChildRequest(childId: 145),
        ],
      );

      final json = req.toJson();
      expect(json['driver_id'], 189);
      expect(json['subscription_type'], 'multi_day');
      expect(json['trip_direction'], 'both');
      expect(json['start_date'], '2026-08-27');
      expect(json['end_date'], '2026-09-30');
      expect(json['home_address_id'], 37);
      expect(json['notes'], contains('يرجى التواصل'));

      final kids = json['children'] as List;
      expect(kids.length, 2);

      expect(kids[0], {'child_id': 144});
      expect(kids[1], {'child_id': 145});
    });

    test('يطابق قيم الأنواع والتنظيف التلقائي للتواريخ', () {
      final req = SubscriptionRequest(
        driverId: 1,
        subscriptionType: 'single_day',
        tripDirection: 'go',
        startDate: '2026-08-27',
        children: [
          SubscriptionChildRequest(childId: 10),
        ],
      );

      expect(req.subscriptionType, 'single_day');
      expect(req.tripDirection, 'go');
      expect(req.toJson()['subscription_type'], 'single_day');
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
      expect(model.statusDisplayLabel, 'قيد الانتظار');
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
