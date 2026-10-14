import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/features/driver/trips/data/models/emergency_dispatch_model.dart';
import 'package:kids_transport/features/driver/trips/data/repositories/driver_emergency_repository.dart';
import 'package:kids_transport/features/driver/trips/logic/driver_emergency_cubit/driver_emergency_cubit.dart';
import 'package:kids_transport/features/driver/trips/presentation/screens/driver_emergency_dispatches_screen.dart';

class ErrorRepo extends Fake implements DriverEmergencyRepository {
  @override
  Future<List<EmergencyDispatchModel>> getAvailableDispatches() async {
    throw Exception('Unexpected null value.');
  }
}

void main() {
  testWidgets('Test DriverEmergencyError state', (tester) async {
    final cubit = DriverEmergencyCubit(ErrorRepo());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(800, 1200),
        builder: (context, child) => MaterialApp(
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

    await gesture.moveTo(tester.getCenter(find.text('إعادة المحاولة')));
    await tester.pumpAndSettle();
  });
}
