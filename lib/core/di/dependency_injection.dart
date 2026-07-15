import 'package:get_it/get_it.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/features/parent/shared/di/parent_injection.dart';
import 'package:kids_transport/features/auth/shared/di/auth_injection.dart';
import 'package:kids_transport/features/auth/login/data/repositories/session_repository.dart';
import 'package:kids_transport/features/app_entry/logic/app_entry_cubit.dart';
import 'package:kids_transport/features/driver/driver_preferences/data/repositories/driver_preferences_repository.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  // ApiClient الموحد
  if (!getIt.isRegistered<ApiClient>()) {
    getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  }

  // تهيئة حقن المميزات
  initParentInjection();
  initAuthInjection();

  // Session Management
  if (!getIt.isRegistered<SessionRepository>()) {
    getIt.registerLazySingleton<SessionRepository>(() => SessionRepository());
  }

  // App Entry Feature
  if (!getIt.isRegistered<AppEntryCubit>()) {
    getIt.registerFactory<AppEntryCubit>(
      () => AppEntryCubit(
        getIt<SessionRepository>(),
        getIt<DriverPreferencesRepository>(),
      ),
    );
  }
}
