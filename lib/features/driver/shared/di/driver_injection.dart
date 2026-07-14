import 'package:get_it/get_it.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/features/driver/driver_preferences/data/datasources/driver_preferences_remote_data_source.dart';
import 'package:kids_transport/features/driver/driver_preferences/data/repositories/driver_preferences_repository.dart';
import 'package:kids_transport/features/driver/driver_preferences/data/repository_impl/driver_preferences_repository_impl.dart';
import 'package:kids_transport/features/driver/driver_preferences/logic/driver_preferences_cubit.dart';

final GetIt driverSl = GetIt.instance;

void initDriverInjection() {
  // Register ApiClient if not already registered
  if (!driverSl.isRegistered<ApiClient>()) {
    driverSl.registerLazySingleton<ApiClient>(() => ApiClient());
  }

  // Datasource
  if (!driverSl.isRegistered<DriverPreferencesRemoteDataSource>()) {
    driverSl.registerLazySingleton<DriverPreferencesRemoteDataSource>(
      () => DriverPreferencesRemoteDataSource(driverSl<ApiClient>()),
    );
  }

  // Repository
  if (!driverSl.isRegistered<DriverPreferencesRepository>()) {
    driverSl.registerLazySingleton<DriverPreferencesRepository>(
      () => DriverPreferencesRepositoryImpl(driverSl<DriverPreferencesRemoteDataSource>()),
    );
  }

  // Cubit
  if (!driverSl.isRegistered<DriverPreferencesCubit>()) {
    driverSl.registerFactory<DriverPreferencesCubit>(
      () => DriverPreferencesCubit(driverSl<DriverPreferencesRepository>()),
    );
  }
}
