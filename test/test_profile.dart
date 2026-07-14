import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/parent/search/presentation/screens/driver_profile_view.dart';
import 'package:kids_transport/features/parent/search/data/models/driver_search_model.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/features/parent/children/logic/children_cubit/children_cubit.dart';
import 'package:kids_transport/features/parent/children/data/repositories/children_repository.dart';
import 'package:kids_transport/features/parent/children/data/datasources/children_remote_data_source.dart';
import 'package:kids_transport/core/network/api_client.dart';

void main() {
  testWidgets('Test DriverProfileView', (WidgetTester tester) async {
    final driver = DriverSearchModel(
      driver: DriverModelInfo(
        id: 1,
        fullName: 'أحمد الوداني',
        gender: 'MALE',
        rating: 4.9,
        completedTrips: 142,
        status: 'active',
        phoneNumber: '091-1234567',
        alternativePhone: '092-1234567',
        shift: 'BOTH',
      ),
      vehicle: VehicleModelInfo(
        brand: 'هونداي',
        model: 'H1 (باص)',
        year: 2020,
        color: 'أبيض',
        type: 'bus',
        hasAc: true,
        capacityManual: 12,
        plateNumber: '12-34567',
      ),
      workingZones: [
        WorkingZoneModelInfo(id: 1, name: 'طرابلس المركز'),
        WorkingZoneModelInfo(id: 2, name: 'جنزور'),
        WorkingZoneModelInfo(id: 3, name: 'عين زارة'),
      ],
      pricing: PricingModelInfo(
        totalPrice: 65.0,
        totalPriceRaw: 65,
        hasAc: true,
        pricePerKm: 2.5,
        childrenCount: 0,
      ),
      breakdown: [],
    );

    final kids = <ChildModel>[];
    final client = ApiClient();
    final dataSource = ChildrenRemoteDataSource(client);
    final repo = ChildrenRepository(dataSource);
    final cubit = ChildrenCubit(repo);

    await tester.pumpWidget(MaterialApp(
      home: BlocProvider<ChildrenCubit>(
        create: (_) => cubit,
        child: DriverProfileView(
          driver: driver,
          availableKids: kids,
          initialSelectedKidsIds: [],
        ),
      ),
    ));

    print('DriverProfileView loaded successfully in test.');
  });
}
