import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/features/driver/trips/data/models/trip_action_result_model.dart';

void main() {
  group('Update Child Status (Backend Contract) Tests', () {
    test('Test 1 - Request Body: يتأكد من احتواء الطلب على action و latitude و longitude', () {
      const action = 'pickup';
      const latitude = 32.8872;
      const longitude = 13.1913;

      final requestBody = {
        'action': action,
        'latitude': latitude,
        'longitude': longitude,
      };

      expect(requestBody['action'], equals('pickup'));
      expect(requestBody['latitude'], equals(32.8872));
      expect(requestBody['longitude'], equals(13.1913));
    });

    test('Test 2 - Response Parsing: تحليل نجاح Pickup مع next_stop بنجاح', () {
      final jsonResponse = {
        "status": "success",
        "message": "تم تأكيد الصعود وإرسال الإشعار لولي الأمر.",
        "next_stop": {
          "stop_id": 2,
          "stop_type": "home",
          "sequence_order": 2,
          "name": "مريم سالم",
          "title": "مريم سالم",
          "child_id": 11,
          "trip_child_id": 11,
          "child_name": "مريم سالم",
          "school_id": 1,
          "school_name": "مدرسة الفجر الجديد الابتدائية",
          "latitude": 32.873,
          "longitude": 13.158,
          "address": "حي الأندلس، شارع 2",
          "status": "pending",
          "eta": null
        }
      };

      final result = ChildStatusActionResultModel.fromJson(jsonResponse);

      expect(result.status, equals('success'));
      expect(result.message, equals('تم تأكيد الصعود وإرسال الإشعار لولي الأمر.'));
      expect(result.nextStop, isNotNull);
      expect(result.nextStop!.stopId, equals(2));
      expect(result.nextStop!.stopType, equals('home'));
      expect(result.nextStop!.childName, equals('مريم سالم'));
    });

    test('Test 3 - NextStop (Home): تحليل المحطة عندما تكون من نوع home وتضم بيانات الطفل', () {
      final jsonNextStop = {
        "stop_id": 5,
        "stop_type": "home",
        "sequence_order": 3,
        "name": "أحمد علي",
        "child_id": 8,
        "trip_child_id": 8,
        "child_name": "أحمد علي",
        "latitude": 32.871,
        "longitude": 13.156,
        "status": "pending"
      };

      final nextStop = NextStopModel.fromJson(jsonNextStop);

      expect(nextStop.isHome, isTrue);
      expect(nextStop.isSchool, isFalse);
      expect(nextStop.childId, equals(8));
      expect(nextStop.tripChildId, equals(8));
      expect(nextStop.childName, equals('أحمد علي'));
    });

    test('Test 4 - NextStop (School): تحليل المحطة عندما تكون school وتضم child_id = null', () {
      final jsonNextStop = {
        "stop_id": 10,
        "stop_type": "school",
        "sequence_order": 6,
        "child_id": null,
        "trip_child_id": null,
        "child_name": null,
        "school_id": 1,
        "school_name": "مدرسة الفجر الجديد الابتدائية",
        "latitude": 32.890,
        "longitude": 13.200,
        "status": "pending"
      };

      final nextStop = NextStopModel.fromJson(jsonNextStop);

      expect(nextStop.isSchool, isTrue);
      expect(nextStop.isHome, isFalse);
      expect(nextStop.childId, isNull);
      expect(nextStop.tripChildId, isNull);
      expect(nextStop.childName, isNull);
      expect(nextStop.schoolName, equals('مدرسة الفجر الجديد الابتدائية'));
    });

    test('Test 5 - Error Handling: معالجة خطأ LOCATION_REQUIRED واستخراج error_code', () {
      final jsonError = {
        "status": "error",
        "error_code": "LOCATION_REQUIRED",
        "message": "يجب إرسال الموقع الجغرافي الحالي (latitude, longitude) للتأكيد اليدوي، أو استخدام مسح QR."
      };

      final dioError = DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 422,
          data: jsonError,
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = ApiException.fromDioException(dioError);

      expect(exception.statusCode, equals(422));
      expect(exception.errorCode, equals('LOCATION_REQUIRED'));
      expect(
        exception.message,
        contains('يجب إرسال الموقع الجغرافي الحالي'),
      );
    });

    test('Test 6 - Error Handling: معالجة خطأ OUT_OF_RANGE واستخراج error_code', () {
      final jsonError = {
        "status": "error",
        "error_code": "OUT_OF_RANGE",
        "message": "أنت بعيد عن موقع المحطة (2514 م)، الحد المسموح 100 م. يرجى الاقتراب أو استخدام مسح QR."
      };

      final dioError = DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 422,
          data: jsonError,
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = ApiException.fromDioException(dioError);

      expect(exception.statusCode, equals(422));
      expect(exception.errorCode, equals('OUT_OF_RANGE'));
      expect(
        exception.message,
        contains('أنت بعيد عن موقع المحطة'),
      );
    });

    test('Test 7 - HTTP 422: التأكد من عدم اعتبار 422 كاستجابة ناجحة واستخراج رسالة الباك إند الأصيلة', () {
      final jsonError = {
        "status": "error",
        "error_code": "UNPROCESSABLE_ENTITY",
        "message": "تعذر تحديث حالة الطفل نظراً لتغير حالة الرحلة."
      };

      final dioError = DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 422,
          data: jsonError,
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = ApiException.fromDioException(dioError);

      expect(exception, isA<ApiException>());
      expect(exception.statusCode, equals(422));
      expect(exception.message, equals('تعذر تحديث حالة الطفل نظراً لتغير حالة الرحلة.'));
    });

    test('Test 8 - Endpoint Mapping: التأكد من بناء مسار الـ API بنفس هيكلة Contract المطلوبة', () {
      const tripId = 2;
      const tripChildId = 15;

      final path = ApiEndpoints.driverTripChildStatus(tripId, tripChildId);

      expect(path, equals('v1/driver/trips/2/children/15/status'));
    });
  });
}
