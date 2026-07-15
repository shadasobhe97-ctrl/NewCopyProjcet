import 'package:get_it/get_it.dart';
import 'package:kids_transport/core/network/api_client.dart';

// Login
import 'package:kids_transport/features/auth/login/data/data_sources/auth_remote_data_source.dart';
import 'package:kids_transport/features/auth/login/data/repositories/auth_repository.dart';
import 'package:kids_transport/features/auth/login/data/repositories/session_repository.dart';
import 'package:kids_transport/features/auth/login/logic/auth_cubit.dart';

// Registration
import 'package:kids_transport/features/auth/registration/data/data_sources/driver_remote_data_source.dart' as reg;
import 'package:kids_transport/features/auth/registration/data/data_sources/parent_remote_data_source.dart' as reg_parent;
import 'package:kids_transport/features/auth/registration/data/repositories/registration_repository.dart';
import 'package:kids_transport/features/auth/registration/logic/register_cubit.dart';

final getIt = GetIt.instance;

void initAuthInjection() {
  // =========================================
  // 1. Login Auth Feature
  // =========================================
  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(apiClient: getIt<ApiClient>()),
    );
  }
  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepository(
        getIt<AuthRemoteDataSource>(),
        getIt<SessionRepository>(),
      ),
    );
  }
  if (!getIt.isRegistered<AuthCubit>()) {
    getIt.registerFactory<AuthCubit>(
      () => AuthCubit(getIt<AuthRepository>()),
    );
  }

  // =========================================
  // 2. Registration Feature
  // =========================================
  if (!getIt.isRegistered<reg.DriverRemoteDataSource>()) {
    getIt.registerLazySingleton<reg.DriverRemoteDataSource>(
      () => reg.DriverRemoteDataSource(apiClient: getIt<ApiClient>()),
    );
  }
  if (!getIt.isRegistered<reg_parent.ParentRemoteDataSource>()) {
    getIt.registerLazySingleton<reg_parent.ParentRemoteDataSource>(
      () => reg_parent.ParentRemoteDataSource(apiClient: getIt<ApiClient>()),
    );
  }
  if (!getIt.isRegistered<RegistrationRepository>()) {
    getIt.registerLazySingleton<RegistrationRepository>(
      () => RegistrationRepository(
        getIt<reg.DriverRemoteDataSource>(),
        getIt<reg_parent.ParentRemoteDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<RegisterCubit>()) {
    getIt.registerFactory<RegisterCubit>(
      () => RegisterCubit(getIt<RegistrationRepository>()),
    );
  }
}
