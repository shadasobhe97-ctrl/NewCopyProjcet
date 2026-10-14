import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/features/driver/trips/data/models/emergency_dispatch_model.dart';
import 'package:kids_transport/features/driver/trips/data/repositories/driver_emergency_repository.dart';
import 'package:kids_transport/features/driver/trips/logic/driver_emergency_cubit/driver_emergency_cubit.dart';
import 'package:kids_transport/features/driver/trips/presentation/screens/driver_emergency_dispatches_screen.dart';
import 'package:kids_transport/features/driver/trips/presentation/screens/emergency_dispatch_details_screen.dart';

class MockRepo extends Fake implements DriverEmergencyRepository {
  final List<EmergencyDispatchModel> dispatches;
  MockRepo(this.dispatches);

  @override
  Future<List<EmergencyDispatchModel>> getAvailableDispatches() async {
    return dispatches;
  }

  @override
  Future<EmergencyDispatchModel> getDispatchDetails(int id) async {
    return dispatches.firstWhere((d) => d.id == id, orElse: () => dispatches.first);
  }
}

void main() {
  testWidgets('Test various null scenarios on DriverEmergencyDispatchesScreen', (tester) async {
    final edgeCaseDispatches = [
      EmergencyDispatchModel(
        id: 1,
        tripId: 10,
        status: 'broadcasted',
        breakdownLat: 0.0,
        breakdownLng: 0.0,
        tripFareAmount: 0.0,
        strandedChildrenCount: 0,
        expiresAt: null, // Null expiresAt
        originalDriver: null, // Null originalDriver
      ),
      EmergencyDispatchModel(
        id: 2,
        tripId: 20,
        status: 'broadcasted',
        breakdownLat: 32.1,
        breakdownLng: 13.1,
        tripFareAmount: 50.0,
        strandedChildrenCount: 5,
        expiresAt: '2026-10-13 14:00:00', // No T
        originalDriver: OriginalDriverModel(id: 3, name: '', phone: ''),
      ),
      EmergencyDispatchModel(
        id: 3,
        tripId: 30,
        status: 'broadcasted',
        breakdownLat: 32.2,
        breakdownLng: 13.2,
        tripFareAmount: 15.0,
        strandedChildrenCount: 1,
        expiresAt: '2026-10-13T', // T but no time
        originalDriver: OriginalDriverModel(id: 4, name: 'سائق', phone: '091'),
      ),
      EmergencyDispatchModel(
        id: 4,
        tripId: 40,
        status: 'broadcasted',
        breakdownLat: 32.3,
        breakdownLng: 13.3,
        tripFareAmount: 20.0,
        strandedChildrenCount: 2,
        expiresAt: '2026-10-13T12:00:00Z', // Standard ISO
        originalDriver: OriginalDriverModel(id: 5, name: 'سائق 2', phone: '092'),
      ),
    ];

    final repo = MockRepo(edgeCaseDispatches);
    final cubit = DriverEmergencyCubit(repo);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(800, 1200),
        builder: (context, child) => MaterialApp(
          theme: AppTheme.lightTheme,
          home: BlocProvider<DriverEmergencyCubit>.value(
            value: cubit,
            child: const DriverEmergencyDispatchesScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify all 4 cards rendered safely without crashes
    expect(find.byType(DriverEmergencyDispatchesScreen), findsOneWidget);

    // Simulate mouse movements across the screen to test mouse tracker
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    await tester.pump();

    await gesture.moveTo(tester.getCenter(find.text('قبول المهمة').first));
    await tester.pumpAndSettle();

    await gesture.moveTo(tester.getCenter(find.text('التفاصيل').first));
    await tester.pumpAndSettle();
  });
}
