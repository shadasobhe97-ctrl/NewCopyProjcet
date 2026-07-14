import 'package:get_it/get_it.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/features/parent/search/data/datasources/search_remote_data_source.dart';
import 'package:kids_transport/features/parent/search/data/repositories/search_repository.dart';
import 'package:kids_transport/features/parent/search/logic/search_cubit.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  // ApiClient
  if (!getIt.isRegistered<ApiClient>()) {
    getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  }

  // Search Data Source
  if (!getIt.isRegistered<SearchRemoteDataSource>()) {
    getIt.registerLazySingleton<SearchRemoteDataSource>(
      () => SearchRemoteDataSource(getIt<ApiClient>()),
    );
  }

  // Search Repository
  if (!getIt.isRegistered<SearchRepository>()) {
    getIt.registerLazySingleton<SearchRepository>(
      () => SearchRepository(getIt<SearchRemoteDataSource>()),
    );
  }

  // Search Cubit
  if (!getIt.isRegistered<SearchCubit>()) {
    getIt.registerFactory<SearchCubit>(
      () => SearchCubit(getIt<SearchRepository>()),
    );
  }
}
