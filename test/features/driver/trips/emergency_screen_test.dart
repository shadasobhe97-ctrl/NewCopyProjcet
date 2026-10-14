import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/features/driver/trips/data/models/emergency_dispatch_model.dart';
import 'package:kids_transport/features/driver/trips/data/repositories/driver_emergency_repository.dart';
import 'package:kids_transport/features/driver/trips/logic/driver_emergency_cubit/driver_emergency_cubit.dart';
import 'package:kids_transport/features/driver/trips/presentation/screens/driver_emergency_dispatches_screen.dart';

class MockRepo extends Fake implements DriverEmergencyRepository {
  final List<EmergencyDispatchModel> dispatches;
  MockRepo(this.dispatches);

  @override
  Future<List<EmergencyDispatchModel>> getAvailableDispatches() async {
    return dispatches;
  }
}

void main() {
  testWidgets('Test DriverEmergencyDispatchesScreen with mouse hover', (tester) async {
    final sampleDispatch = EmergencyDispatchModel(
      id: 1,
      tripId: 10,
      status: 'broadcasted',
      breakdownLat: 32.88,
      breakdownLng: 13.18,
      tripFareAmount: 25.0,
      strandedChildrenCount: 3,
      expiresAt: '2026-10-13T14:30:00Z',
      originalDriver: OriginalDriverModel(id: 2, name: 'سائق تجريبي', phone: '0912345678'),
    );

    final repo = MockRepo([sampleDispatch]);
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

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    await tester.pump();

    // Hover over elements
    await gesture.moveTo(tester.getCenter(find.text('قبول المهمة')));
    await tester.pumpAndSettle();

    await gesture.moveTo(tester.getCenter(find.byType(IconButton).last));
    await tester.pumpAndSettle();
  });
}
