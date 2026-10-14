import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/driver/trips/data/models/emergency_dispatch_model.dart';
import 'package:kids_transport/features/driver/trips/data/repositories/driver_emergency_repository.dart';
import 'package:kids_transport/features/driver/trips/logic/driver_emergency_cubit/driver_emergency_cubit.dart';
import 'package:kids_transport/features/driver/trips/presentation/screens/emergency_dispatch_details_screen.dart';

class MockDetailsRepo extends Fake implements DriverEmergencyRepository {
  final EmergencyDispatchModel dispatch;
  MockDetailsRepo(this.dispatch);

  @override
  Future<EmergencyDispatchModel> getDispatchDetails(int id) async {
    return dispatch;
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'driver_id': 1});
    await StorageService.init();
  });

  testWidgets('Test EmergencyDispatchDetailsScreen renders correctly', (tester) async {
    final sample = EmergencyDispatchModel(
      id: 5,
      tripId: 10,
      status: 'broadcasted',
      breakdownLat: 32.8,
      breakdownLng: 13.1,
      tripFareAmount: 30.0,
      strandedChildrenCount: 2,
      originalDriver: OriginalDriverModel(id: 1, name: 'سائق', phone: '091'),
      trip: DispatchTripInfo(
        id: 10,
        tripType: 'morning',
        status: 'suspended_breakdown',
        stops: [
          DispatchStopInfo(
            id: 1,
            stopType: 'home',
            sequenceOrder: 1,
            status: 'pending',
            label: 'محطة 1',
            lat: 32.8,
            lng: 13.1,
            child: DispatchChildInfo(id: 10, fullName: 'أحمد', schoolName: 'مدرسة الأمل'),
          ),
        ],
      ),
    );

    final repo = MockDetailsRepo(sample);
    final cubit = DriverEmergencyCubit(repo);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(800, 1200),
        builder: (context, child) => MaterialApp(
          home: BlocProvider<DriverEmergencyCubit>.value(
            value: cubit,
            child: const EmergencyDispatchDetailsScreen(dispatchId: 5),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('تفاصيل المهمة الطارئة'), findsOneWidget);
    expect(find.text('أحمد'), findsOneWidget);
  });
}
