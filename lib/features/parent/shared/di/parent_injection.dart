import 'package:get_it/get_it.dart';
import 'package:kids_transport/core/network/api_client.dart';

// Requests (Guardian Requests)
import 'package:kids_transport/features/parent/subscriptions/data/datasources/requests_remote_data_source.dart';
import 'package:kids_transport/features/parent/subscriptions/data/repositories/requests_repository.dart';

// Trips & Live Tracking
import 'package:kids_transport/features/parent/trips/data/datasources/trips_remote_data_source.dart';
import 'package:kids_transport/features/parent/trips/data/repositories/trips_repository.dart';
import 'package:kids_transport/features/parent/trips/logic/active_trip_cubit/active_trip_cubit.dart';
import 'package:kids_transport/features/parent/trips/logic/trip_tracking_cubit/trip_tracking_cubit.dart';
import 'package:kids_transport/features/parent/trips/logic/upcoming_trips_cubit/upcoming_trips_cubit.dart';
import 'package:kids_transport/features/parent/trips/logic/trip_history_cubit/trip_history_cubit.dart';

// Search
import 'package:kids_transport/features/parent/search/data/datasources/search_remote_data_source.dart';
import 'package:kids_transport/features/parent/search/data/repositories/search_repository.dart';
import 'package:kids_transport/features/parent/search/logic/search_cubit.dart';
import 'package:kids_transport/features/parent/reviews/data/datasource/reviews_remote_data_source.dart';
import 'package:kids_transport/features/parent/reviews/data/repositories/reviews_repository.dart';
import 'package:kids_transport/features/parent/reviews/logic/reviews_cubit.dart';

// Complaints
import 'package:kids_transport/features/parent/complaints/data/datasources/complaints_remote_data_source.dart';
import 'package:kids_transport/features/parent/complaints/data/repositories/complaints_repository.dart';
import 'package:kids_transport/features/parent/complaints/logic/complaints_cubit.dart';

// Wallet & Finance
import 'package:kids_transport/features/parent/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:kids_transport/features/parent/wallet/data/datasources/invoices_remote_data_source.dart';
import 'package:kids_transport/features/parent/wallet/data/repositories/wallet_repository.dart';
import 'package:kids_transport/features/parent/wallet/data/repositories/invoices_repository.dart';
import 'package:kids_transport/features/parent/wallet/logic/wallet_cubit/wallet_cubit.dart';
import 'package:kids_transport/features/parent/wallet/logic/invoices_cubit/invoices_cubit.dart';
import 'package:kids_transport/features/parent/wallet/logic/invoice_details_cubit/invoice_details_cubit.dart';

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

  // Reviews & Ratings
  if (!getIt.isRegistered<ReviewsRemoteDataSource>()) {
    getIt.registerLazySingleton<ReviewsRemoteDataSource>(
      () => ReviewsRemoteDataSource(getIt<ApiClient>()),
    );
  }
  if (!getIt.isRegistered<ReviewsRepository>()) {
    getIt.registerLazySingleton<ReviewsRepository>(
      () => ReviewsRepository(getIt<ReviewsRemoteDataSource>()),
    );
  }
  if (!getIt.isRegistered<ReviewsCubit>()) {
    getIt.registerFactory<ReviewsCubit>(
      () => ReviewsCubit(getIt<ReviewsRepository>()),
    );
  }

  // Complaints
  if (!getIt.isRegistered<ComplaintsRemoteDataSource>()) {
    getIt.registerLazySingleton<ComplaintsRemoteDataSource>(
      () => ComplaintsRemoteDataSource(getIt<ApiClient>()),
    );
  }
  if (!getIt.isRegistered<ComplaintsRepository>()) {
    getIt.registerLazySingleton<ComplaintsRepository>(
      () => ComplaintsRepository(getIt<ComplaintsRemoteDataSource>()),
    );
  }
  if (!getIt.isRegistered<ComplaintsCubit>()) {
    getIt.registerFactory<ComplaintsCubit>(
      () => ComplaintsCubit(getIt<ComplaintsRepository>()),
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

  // =========================================
  // 6. Guardian Requests Feature
  // =========================================
  if (!getIt.isRegistered<RequestsRemoteDataSource>()) {
    getIt.registerLazySingleton<RequestsRemoteDataSource>(
      () => RequestsRemoteDataSource(getIt<ApiClient>()),
    );
  }
  if (!getIt.isRegistered<RequestsRepository>()) {
    getIt.registerLazySingleton<RequestsRepository>(
      () => RequestsRepository(getIt<RequestsRemoteDataSource>()),
    );
  }

  // =========================================
  // 7. Wallet & Finance Feature
  // =========================================
  // Remote Data Sources
  if (!getIt.isRegistered<WalletRemoteDataSource>()) {
    getIt.registerLazySingleton<WalletRemoteDataSource>(
      () => WalletRemoteDataSource(getIt<ApiClient>()),
    );
  }
  if (!getIt.isRegistered<InvoicesRemoteDataSource>()) {
    getIt.registerLazySingleton<InvoicesRemoteDataSource>(
      () => InvoicesRemoteDataSource(getIt<ApiClient>()),
    );
  }
  
  // Repositories
  if (!getIt.isRegistered<WalletRepository>()) {
    getIt.registerLazySingleton<WalletRepository>(
      () => WalletRepository(getIt<WalletRemoteDataSource>()),
    );
  }
  if (!getIt.isRegistered<InvoicesRepository>()) {
    getIt.registerLazySingleton<InvoicesRepository>(
      () => InvoicesRepository(getIt<InvoicesRemoteDataSource>()),
    );
  }
  
  // Cubits
  if (!getIt.isRegistered<WalletCubit>()) {
    getIt.registerFactory<WalletCubit>(
      () => WalletCubit(getIt<WalletRepository>()),
    );
  }
  if (!getIt.isRegistered<InvoicesCubit>()) {
    getIt.registerFactory<InvoicesCubit>(
      () => InvoicesCubit(getIt<InvoicesRepository>()),
    );
  }
  if (!getIt.isRegistered<InvoiceDetailsCubit>()) {
    getIt.registerFactory<InvoiceDetailsCubit>(
      () => InvoiceDetailsCubit(getIt<InvoicesRepository>()),
    );
  }

  // =========================================
  // 8. Trips & Live Tracking Feature
  // =========================================
  if (!getIt.isRegistered<TripsRemoteDataSource>()) {
    getIt.registerLazySingleton<TripsRemoteDataSource>(
      () => TripsRemoteDataSource(getIt<ApiClient>()),
    );
  }
  if (!getIt.isRegistered<TripsRepository>()) {
    getIt.registerLazySingleton<TripsRepository>(
      () => TripsRepository(getIt<TripsRemoteDataSource>()),
    );
  }
  if (!getIt.isRegistered<ActiveTripCubit>()) {
    getIt.registerFactory<ActiveTripCubit>(
      () => ActiveTripCubit(getIt<TripsRepository>()),
    );
  }
  if (!getIt.isRegistered<TripTrackingCubit>()) {
    getIt.registerFactory<TripTrackingCubit>(
      () => TripTrackingCubit(getIt<TripsRepository>()),
    );
  }
  if (!getIt.isRegistered<UpcomingTripsCubit>()) {
    getIt.registerFactory<UpcomingTripsCubit>(
      () => UpcomingTripsCubit(getIt<TripsRepository>()),
    );
  }
  if (!getIt.isRegistered<TripHistoryCubit>()) {
    getIt.registerFactory<TripHistoryCubit>(
      () => TripHistoryCubit(getIt<TripsRepository>()),
    );
  }
}
