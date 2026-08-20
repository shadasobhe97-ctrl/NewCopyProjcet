import 'package:get_it/get_it.dart';
import 'package:kids_transport/core/network/api_client.dart';

// Preferences
import 'package:kids_transport/features/driver/driver_preferences/data/datasources/driver_preferences_remote_data_source.dart';
import 'package:kids_transport/features/driver/driver_preferences/data/repositories/driver_preferences_repository.dart';
import 'package:kids_transport/features/driver/driver_preferences/data/repository_impl/driver_preferences_repository_impl.dart';
import 'package:kids_transport/features/driver/driver_preferences/logic/driver_preferences_cubit.dart';

// Profile
import 'package:kids_transport/features/driver/profile/data/data_sources/driver_profile_remote_data_source.dart';
import 'package:kids_transport/features/driver/profile/data/repositories/driver_profile_repository.dart';
import 'package:kids_transport/features/driver/profile/logic/cubit/driver_profile_cubit.dart';
import 'package:kids_transport/features/driver/profile/logic/cubit/driver_legal_data_cubit.dart';
import 'package:kids_transport/features/auth/login/data/repositories/session_repository.dart';

// Vehicles
import 'package:kids_transport/features/driver/vehicles/data/data_sources/vehicle_remote_data_source.dart';
import 'package:kids_transport/features/driver/vehicles/data/repositories/vehicle_repository.dart';
import 'package:kids_transport/features/driver/vehicles/logic/vehicle_cubit.dart';

// Requests
import 'package:kids_transport/features/driver/requests/data/datasources/driver_requests_remote_data_source.dart';
import 'package:kids_transport/features/driver/requests/data/repositories/driver_requests_repository.dart';
import 'package:kids_transport/features/driver/requests/logic/driver_requests_cubit.dart';

// Subscriptions
import 'package:kids_transport/features/driver/subscriptions/data/datasources/driver_subscriptions_remote_data_source.dart';
import 'package:kids_transport/features/driver/subscriptions/data/repositories/driver_subscriptions_repository.dart';
import 'package:kids_transport/features/driver/subscriptions/logic/driver_subscriptions_cubit.dart';

// Finance
import 'package:kids_transport/features/driver/finance/data/datasources/finance_remote_data_source.dart';
import 'package:kids_transport/features/driver/finance/data/repositories/finance_repository.dart';
import 'package:kids_transport/features/driver/finance/logic/cubit/finance_cubit.dart';

// Trips
import 'package:kids_transport/features/driver/trips/data/datasources/driver_trips_remote_data_source.dart';
import 'package:kids_transport/features/driver/trips/data/repositories/driver_trips_repository.dart';
import 'package:kids_transport/features/driver/trips/logic/driver_trips_cubit/driver_trips_cubit.dart';
import 'package:kids_transport/features/driver/trips/logic/live_trip_cubit/live_trip_cubit.dart';
import 'package:kids_transport/features/driver/trips/logic/driver_trips_history_cubit/driver_trips_history_cubit.dart';
import 'package:kids_transport/features/driver/trips/logic/driver_absence_cubit/driver_absence_cubit.dart';

final GetIt driverSl = GetIt.instance;

void initDriverInjection() {
  // =========================================
  // 1. Preferences Feature
  // =========================================
  if (!driverSl.isRegistered<DriverPreferencesRemoteDataSource>()) {
    driverSl.registerLazySingleton<DriverPreferencesRemoteDataSource>(
      () => DriverPreferencesRemoteDataSource(driverSl<ApiClient>()),
    );
  }
  if (!driverSl.isRegistered<DriverPreferencesRepository>()) {
    driverSl.registerLazySingleton<DriverPreferencesRepository>(
      () => DriverPreferencesRepositoryImpl(driverSl<DriverPreferencesRemoteDataSource>()),
    );
  }
  if (!driverSl.isRegistered<DriverPreferencesCubit>()) {
    driverSl.registerFactory<DriverPreferencesCubit>(
      () => DriverPreferencesCubit(driverSl<DriverPreferencesRepository>()),
    );
  }

  // =========================================
  // 2. Profile Feature
  // =========================================
  if (!driverSl.isRegistered<DriverProfileRemoteDataSource>()) {
    driverSl.registerLazySingleton<DriverProfileRemoteDataSource>(
      () => DriverProfileRemoteDataSource(apiClient: driverSl<ApiClient>()),
    );
  }
  if (!driverSl.isRegistered<DriverProfileRepository>()) {
    driverSl.registerLazySingleton<DriverProfileRepository>(
      () => DriverProfileRepository(
        remoteDataSource: driverSl<DriverProfileRemoteDataSource>(),
        sessionRepository: driverSl<SessionRepository>(),
      ),
    );
  }
  if (!driverSl.isRegistered<DriverProfileCubit>()) {
    driverSl.registerFactory<DriverProfileCubit>(
      () => DriverProfileCubit(driverSl<DriverProfileRepository>()),
    );
  }
  if (!driverSl.isRegistered<DriverLegalDataCubit>()) {
    driverSl.registerFactory<DriverLegalDataCubit>(
      () => DriverLegalDataCubit(driverSl<DriverProfileRepository>()),
    );
  }

  // =========================================
  // 3. Vehicles Feature
  // =========================================
  if (!driverSl.isRegistered<VehicleRemoteDataSource>()) {
    driverSl.registerLazySingleton<VehicleRemoteDataSource>(
      () => VehicleRemoteDataSource(driverSl<ApiClient>()),
    );
  }
  if (!driverSl.isRegistered<VehicleRepository>()) {
    driverSl.registerLazySingleton<VehicleRepository>(
      () => VehicleRepository(driverSl<VehicleRemoteDataSource>()),
    );
  }
  if (!driverSl.isRegistered<VehicleCubit>()) {
    driverSl.registerFactory<VehicleCubit>(
      () => VehicleCubit(driverSl<VehicleRepository>()),
    );
  }

  // =========================================
  // 4. Requests Feature
  // =========================================
  if (!driverSl.isRegistered<DriverRequestsRemoteDataSource>()) {
    driverSl.registerLazySingleton<DriverRequestsRemoteDataSource>(
      () => DriverRequestsRemoteDataSource(driverSl<ApiClient>()),
    );
  }
  if (!driverSl.isRegistered<DriverRequestsRepository>()) {
    driverSl.registerLazySingleton<DriverRequestsRepository>(
      () => DriverRequestsRepository(driverSl<DriverRequestsRemoteDataSource>()),
    );
  }
  if (!driverSl.isRegistered<DriverRequestsCubit>()) {
    driverSl.registerFactory<DriverRequestsCubit>(
      () => DriverRequestsCubit(driverSl<DriverRequestsRepository>()),
    );
  }

  // =========================================
  // 5. Subscriptions Feature
  // =========================================
  if (!driverSl.isRegistered<DriverSubscriptionsRemoteDataSource>()) {
    driverSl.registerLazySingleton<DriverSubscriptionsRemoteDataSource>(
      () => DriverSubscriptionsRemoteDataSource(driverSl<ApiClient>()),
    );
  }
  if (!driverSl.isRegistered<DriverSubscriptionsRepository>()) {
    driverSl.registerLazySingleton<DriverSubscriptionsRepository>(
      () => DriverSubscriptionsRepository(driverSl<DriverSubscriptionsRemoteDataSource>()),
    );
  }
  if (!driverSl.isRegistered<DriverSubscriptionsCubit>()) {
    driverSl.registerFactory<DriverSubscriptionsCubit>(
      () => DriverSubscriptionsCubit(driverSl<DriverSubscriptionsRepository>()),
    );
  }

  // =========================================
  // 6. Finance Feature
  // =========================================
  if (!driverSl.isRegistered<FinanceRemoteDataSource>()) {
    driverSl.registerLazySingleton<FinanceRemoteDataSource>(
      () => FinanceRemoteDataSource(driverSl<ApiClient>()),
    );
  }
  if (!driverSl.isRegistered<FinanceRepository>()) {
    driverSl.registerLazySingleton<FinanceRepository>(
      () => FinanceRepository(driverSl<FinanceRemoteDataSource>()),
    );
  }
  if (!driverSl.isRegistered<FinanceCubit>()) {
    driverSl.registerFactory<FinanceCubit>(
      () => FinanceCubit(driverSl<FinanceRepository>()),
    );
  }

  // =========================================
  // 7. Trips Feature
  // =========================================
  if (!driverSl.isRegistered<DriverTripsRemoteDataSource>()) {
    driverSl.registerLazySingleton<DriverTripsRemoteDataSource>(
      () => DriverTripsRemoteDataSource(driverSl<ApiClient>()),
    );
  }
  if (!driverSl.isRegistered<DriverTripsRepository>()) {
    driverSl.registerLazySingleton<DriverTripsRepository>(
      () => DriverTripsRepository(driverSl<DriverTripsRemoteDataSource>()),
    );
  }
  if (!driverSl.isRegistered<DriverTripsCubit>()) {
    driverSl.registerFactory<DriverTripsCubit>(
      () => DriverTripsCubit(driverSl<DriverTripsRepository>()),
    );
  }
  if (!driverSl.isRegistered<LiveTripCubit>()) {
    driverSl.registerFactory<LiveTripCubit>(
      () => LiveTripCubit(driverSl<DriverTripsRepository>()),
    );
  }
  if (!driverSl.isRegistered<DriverTripsHistoryCubit>()) {
    driverSl.registerFactory<DriverTripsHistoryCubit>(
      () => DriverTripsHistoryCubit(driverSl<DriverTripsRepository>()),
    );
  }
  if (!driverSl.isRegistered<DriverAbsenceCubit>()) {
    driverSl.registerFactory<DriverAbsenceCubit>(
      () => DriverAbsenceCubit(driverSl<DriverTripsRepository>()),
    );
  }
}

