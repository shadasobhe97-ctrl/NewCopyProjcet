import 'package:flutter_test/flutter_test.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_absence_model.dart';
import 'package:kids_transport/features/driver/trips/logic/driver_absence_cubit/driver_absence_cubit.dart';
import 'package:kids_transport/features/driver/trips/data/repositories/driver_trips_repository.dart';

class FakeDriverTripsRepository extends Fake implements DriverTripsRepository {
  List<UpcomingAbsenceTripModel> upcomingTripsToReturn = const [];
  DriverRegisterAbsenceResponseModel? responseToReturn;
  DriverRegisterAbsenceRequestModel? lastRequest;
  List<String>? lastDates;
  bool shouldThrowError = false;

  @override
  Future<List<UpcomingAbsenceTripModel>> getUpcomingTripsForAbsence() async {
    if (shouldThrowError) throw Exception('API Error');
    return upcomingTripsToReturn;
  }

  @override
  Future<DriverRegisterAbsenceResponseModel> registerAbsenceWithTrips(
    DriverRegisterAbsenceRequestModel request,
  ) async {
    if (shouldThrowError) throw Exception('Register Failed');
    lastRequest = request;
    return responseToReturn ??
        DriverRegisterAbsenceResponseModel(
          absenceId: 12,
          driverId: 7,
          absenceDate: request.date,
          reason: request.reason,
          status: 'approved',
          tripIds: request.tripIds,
          trips: const [],
        );
  }

  @override
  Future<void> registerAbsence(List<String> dates) async {
    if (shouldThrowError) throw Exception('Register Failed');
    lastDates = dates;
  }
}

void main() {
  late FakeDriverTripsRepository fakeRepository;
  late DriverAbsenceCubit cubit;

  setUp(() {
    fakeRepository = FakeDriverTripsRepository();
    cubit = DriverAbsenceCubit(fakeRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('Driver Absence API Contract & Cubit Tests', () {
    test('Test 1 & 2 & 3 - Fetch Upcoming Trips & Parsing: جلب الرحلات القادمة وتفكيك trip_date', () async {
      final upcomingJson = [
        {
          "id": 501,
          "trip_type": "Morning",
          "shift_slot": "morning_go",
          "trip_date": "2026-09-02",
          "scheduled_start_time": "07:00:00",
          "status": "pending",
          "route_name": "مسار الصباح حي الأندلس"
        },
        {
          "id": 502,
          "trip_type": "Return",
          "shift_slot": "return_back",
          "trip_date": "2026-09-02",
          "scheduled_start_time": "11:30:00",
          "status": "pending",
          "route_name": "مسار العودة"
        }
      ];

      fakeRepository.upcomingTripsToReturn = upcomingJson
          .map((e) => UpcomingAbsenceTripModel.fromJson(e))
          .toList();

      await cubit.loadUpcomingTrips();

      expect(cubit.state.upcomingTrips.length, equals(2));
      expect(cubit.state.upcomingTrips[0].id, equals(501));
      expect(cubit.state.upcomingTrips[0].tripDate, equals('2026-09-02'));
      expect(cubit.state.selectedDate, equals('2026-09-02'));
      expect(cubit.state.tripsForSelectedDate.length, equals(2));
    });

    test('Test 4 - Single Trip Selection: اختيار رحلة واحدة', () {
      cubit.toggleTripSelection(501);

      expect(cubit.state.selectedTripIds.contains(501), isTrue);
      expect(cubit.state.selectedTripIds.length, equals(1));
    });

    test('Test 5 - Multiple Trip Selection: اختيار أكثر من رحلة', () {
      cubit.toggleTripSelection(501);
      cubit.toggleTripSelection(502);

      expect(cubit.state.selectedTripIds.contains(501), isTrue);
      expect(cubit.state.selectedTripIds.contains(502), isTrue);
      expect(cubit.state.selectedTripIds.length, equals(2));
    });

    test('Test 6 & 7 & 8 & 9 - Request Construction: إنشاء Request صحيح بإرسال date بصيغة yyyy-MM-dd و trip_ids و reason', () {
      const request = DriverRegisterAbsenceRequestModel(
        date: '2026-09-02',
        tripIds: [501, 502],
        reason: 'عطل في محرك السيارة',
      );

      final json = request.toJson();

      expect(json['date'], equals('2026-09-02'));
      expect(json['trip_ids'], equals([501, 502]));
      expect(json['reason'], equals('عطل في محرك السيارة'));
    });

    test('Test 10 & 11 & 12 & 13 - Response Parsing & Approved Status: تفكيك Response واستخراج absence_id والتأكد أن status = approved ولا يعامل كـ pending', () {
      final responseJson = {
        "status": "success",
        "message": "تم تسجيل غيابك عن الرحلات المحددة فوراً، وفصلك عنها.",
        "data": {
          "absence_id": 12,
          "driver_id": 7,
          "absence_date": "2026-09-02",
          "reason": "عطل في محرك السيارة",
          "status": "approved",
          "trip_ids": [501, 502],
          "trips": [
            {
              "id": 501,
              "trip_type": "Morning",
              "shift_slot": "morning_go",
              "trip_date": "2026-09-02",
              "status": "pending",
              "scheduled_start_time": "07:00:00"
            }
          ]
        }
      };

      final responseModel = DriverRegisterAbsenceResponseModel.fromJson(
        responseJson['data'] as Map<String, dynamic>,
      );

      expect(responseModel.absenceId, equals(12));
      expect(responseModel.driverId, equals(7));
      expect(responseModel.absenceDate, equals('2026-09-02'));
      expect(responseModel.reason, equals('عطل في محرك السيارة'));
      expect(responseModel.status, equals('approved'));
      expect(responseModel.isApproved, isTrue);
      expect(responseModel.status, isNot(equals('pending')));
      expect(responseModel.tripIds, equals([501, 502]));
      expect(responseModel.trips.length, equals(1));
    });

    test('Test 14 - Empty Trips List: التعامل مع قائمة رحلات فارغة بمرونة دون Crashes', () async {
      fakeRepository.upcomingTripsToReturn = [];

      await cubit.loadUpcomingTrips();

      expect(cubit.state.upcomingTrips, isEmpty);
      expect(cubit.state.availableDates, isEmpty);
      expect(cubit.state.tripsForSelectedDate, isEmpty);
    });

    test('Test 15 - Prevent Submit Without Trip: منع الإرسال بدون تحديد رحلة', () async {
      cubit.selectDate('2026-09-02');
      cubit.updateReason('عطل في السيارة');

      await cubit.submitAbsenceWithTrips();

      expect(cubit.state.submitStatus, equals(DriverAbsenceSubmitStatus.error));
      expect(cubit.state.errorMessage, equals('يرجى تحديد رحلة واحدة على الأقل للغياب عنها.'));
      expect(fakeRepository.lastRequest, isNull);
    });

    test('Test 16 - Prevent Submit Without Date: منع الإرسال بدون تاريخ', () async {
      cubit.updateReason('عطل في السيارة');

      await cubit.submitAbsenceWithTrips();

      expect(cubit.state.submitStatus, equals(DriverAbsenceSubmitStatus.error));
      expect(cubit.state.errorMessage, equals('يرجى اختيار تاريخ الغياب أولاً.'));
      expect(fakeRepository.lastRequest, isNull);
    });

    test('Test 17 - Legacy Mode Compatibility: الحفاظ على التوافقية مع التواريخ القديمة دون كسر الاختبارات', () async {
      final date = DateTime(2026, 9, 2);
      cubit.toggleDate(date);
      await cubit.submit();

      expect(cubit.state.submitStatus, equals(DriverAbsenceSubmitStatus.success));
      expect(fakeRepository.lastDates, equals(['2026-09-02']));
    });
  });
}
