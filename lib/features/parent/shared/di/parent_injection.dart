import 'package:get_it/get_it.dart';
import 'package:kids_transport/core/network/api_client.dart';

// Search
import 'package:kids_transport/features/parent/search/data/datasources/search_remote_data_source.dart';
import 'package:kids_transport/features/parent/search/data/repositories/search_repository.dart';
import 'package:kids_transport/features/parent/search/logic/search_cubit.dart';

// Profile
import 'package:kids_transport/features/parent/profile/data/datasources/parent_profile_remote_data_source.dart';
import 'package:kids_transport/features/parent/profile/data/repositories/parent_profile_repository.dart';
import 'package:kids_transport/features/parent/profile/logic/cubit/parent_profile_cubit.dart';
import 'package:kids_transport/features/auth/login/data/repositories/session_repository.dart';

// Addresses
import 'package:kids_transport/features/parent/addresses/data/datasources/address_remote_data_source.dart';
import 'package:kids_transport/data/local/address_local_data_source.dart';
import 'package:kids_transport/features/parent/addresses/data/repositories/address_repository.dart';
import 'package:kids_transport/features/parent/addresses/logic/address_cubit/address_cubit.dart';

// Children
import 'package:kids_transport/features/parent/children/data/datasources/children_remote_data_source.dart';
import 'package:kids_transport/data/local/children_local_data_source.dart';
import 'package:kids_transport/features/parent/children/data/repositories/children_repository.dart';
import 'package:kids_transport/features/parent/children/logic/children_cubit/children_cubit.dart';
import 'package:kids_transport/features/parent/children/logic/children_cubit/add_child_cubit.dart';

// Subscriptions
import 'package:kids_transport/features/parent/subscriptions/data/datasources/subscriptions_remote_data_source.dart';
import 'package:kids_transport/data/local/subscriptions_local_data_source.dart';
import 'package:kids_transport/features/parent/subscriptions/data/repositories/subscriptions_repository.dart';
import 'package:kids_transport/features/parent/subscriptions/logic/subscriptions_cubit/subscriptions_cubit.dart';

final getIt = GetIt.instance;

void initParentInjection() {
  // =========================================
  // 1. Search Feature
  // =========================================
  if (!getIt.isRegistered<SearchRemoteDataSource>()) {
    getIt.registerLazySingleton<SearchRemoteDataSource>(
      () => SearchRemoteDataSource(getIt<ApiClient>()),
    );
  }
  if (!getIt.isRegistered<SearchRepository>()) {
    getIt.registerLazySingleton<SearchRepository>(
      () => SearchRepository(getIt<SearchRemoteDataSource>()),
    );
  }
  if (!getIt.isRegistered<SearchCubit>()) {
    getIt.registerFactory<SearchCubit>(
      () => SearchCubit(getIt<SearchRepository>()),
    );
  }

  // =========================================
  // 2. Profile Feature
  // =========================================
  if (!getIt.isRegistered<ParentProfileRemoteDataSource>()) {
    getIt.registerLazySingleton<ParentProfileRemoteDataSource>(
      () => ParentProfileRemoteDataSource(getIt<ApiClient>()),
    );
  }
  if (!getIt.isRegistered<ParentProfileRepository>()) {
    getIt.registerLazySingleton<ParentProfileRepository>(
      () => ParentProfileRepository(
        remoteDataSource: getIt<ParentProfileRemoteDataSource>(),
        sessionRepository: getIt<SessionRepository>(),
      ),
    );
  }
  if (!getIt.isRegistered<ParentProfileCubit>()) {
    getIt.registerFactory<ParentProfileCubit>(
      () => ParentProfileCubit(getIt<ParentProfileRepository>()),
    );
  }

  // =========================================
  // 3. Addresses Feature
  // =========================================
  if (!getIt.isRegistered<AddressRemoteDataSource>()) {
    getIt.registerLazySingleton<AddressRemoteDataSource>(
      () => AddressRemoteDataSource(getIt<ApiClient>()),
    );
  }
  if (!getIt.isRegistered<AddressLocalDataSource>()) {
    getIt.registerLazySingleton<AddressLocalDataSource>(
      () => AddressLocalDataSourceImpl(),
    );
  }
  if (!getIt.isRegistered<AddressRepository>()) {
    getIt.registerLazySingleton<AddressRepository>(
      () => AddressRepository(
        getIt<AddressRemoteDataSource>(),
        getIt<AddressLocalDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<AddressCubit>()) {
    getIt.registerFactory<AddressCubit>(
      () => AddressCubit(getIt<AddressRepository>()),
    );
  }

  // =========================================
  // 4. Children Feature
  // =========================================
  if (!getIt.isRegistered<ChildrenRemoteDataSource>()) {
    getIt.registerLazySingleton<ChildrenRemoteDataSource>(
      () => ChildrenRemoteDataSource(getIt<ApiClient>()),
    );
  }
  if (!getIt.isRegistered<ChildrenLocalDataSource>()) {
    getIt.registerLazySingleton<ChildrenLocalDataSource>(
      () => ChildrenLocalDataSourceImpl(),
    );
  }
  if (!getIt.isRegistered<ChildrenRepository>()) {
    getIt.registerLazySingleton<ChildrenRepository>(
      () => ChildrenRepository(
        getIt<ChildrenRemoteDataSource>(),
        getIt<ChildrenLocalDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<ChildrenCubit>()) {
    getIt.registerFactory<ChildrenCubit>(
      () => ChildrenCubit(getIt<ChildrenRepository>()),
    );
  }
  if (!getIt.isRegistered<AddChildCubit>()) {
    getIt.registerFactory<AddChildCubit>(
      () => AddChildCubit(getIt<ChildrenRepository>()),
    );
  }

  // =========================================
  // 5. Subscriptions Feature
  // =========================================
  if (!getIt.isRegistered<SubscriptionsRemoteDataSource>()) {
    getIt.registerLazySingleton<SubscriptionsRemoteDataSource>(
      () => SubscriptionsRemoteDataSource(getIt<ApiClient>()),
    );
  }
  if (!getIt.isRegistered<SubscriptionsLocalDataSource>()) {
    getIt.registerLazySingleton<SubscriptionsLocalDataSource>(
      () => SubscriptionsLocalDataSourceImpl(),
    );
  }
  if (!getIt.isRegistered<SubscriptionsRepository>()) {
    getIt.registerLazySingleton<SubscriptionsRepository>(
      () => SubscriptionsRepository(
        getIt<SubscriptionsRemoteDataSource>(),
        getIt<SubscriptionsLocalDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<SubscriptionsCubit>()) {
    getIt.registerFactory<SubscriptionsCubit>(
      () => SubscriptionsCubit(getIt<SubscriptionsRepository>()),
    );
  }
}
