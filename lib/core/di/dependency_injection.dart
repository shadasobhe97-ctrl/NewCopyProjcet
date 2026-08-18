import 'package:kids_transport/core/network/notification_remote_datasource.dart';
import 'package:kids_transport/core/network/notification_repository.dart';
import 'package:kids_transport/core/logic/cubit/notification_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/features/parent/shared/di/parent_injection.dart';
import 'package:kids_transport/features/auth/shared/di/auth_injection.dart';
import 'package:kids_transport/features/auth/login/data/repositories/session_repository.dart';
import 'package:kids_transport/features/app_entry/logic/app_entry_cubit.dart';
import 'package:kids_transport/features/driver/driver_preferences/data/repositories/driver_preferences_repository.dart';

// Chat Feature Imports
import 'package:kids_transport/features/chat/data/datasources/chat_api_datasource.dart';
import 'package:kids_transport/features/chat/data/datasources/chat_firebase_datasource.dart';
import 'package:kids_transport/features/chat/data/repositories/chat_repository.dart';
import 'package:kids_transport/features/chat/presentation/cubit/chat_list_cubit.dart';
import 'package:kids_transport/features/chat/presentation/cubit/chat_room_cubit.dart';

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

  // Chat Feature Registration
  if (!getIt.isRegistered<ChatApiDataSource>()) {
    getIt.registerLazySingleton<ChatApiDataSource>(
      () => ChatApiDataSource(getIt<ApiClient>()),
    );
  }
  if (!getIt.isRegistered<ChatFirebaseDataSource>()) {
    getIt.registerLazySingleton<ChatFirebaseDataSource>(
      () => ChatFirebaseDataSource(FirebaseFirestore.instance),
    );
  }
  if (!getIt.isRegistered<ChatRepository>()) {
    getIt.registerLazySingleton<ChatRepository>(
      () => ChatRepository(
        getIt<ChatApiDataSource>(),
        getIt<ChatFirebaseDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<ChatListCubit>()) {
    getIt.registerFactory<ChatListCubit>(
      () => ChatListCubit(getIt<ChatRepository>()),
    );
  }
  if (!getIt.isRegistered<ChatRoomCubit>()) {
    getIt.registerFactory<ChatRoomCubit>(
      () => ChatRoomCubit(getIt<ChatRepository>()),
    );
  }

  // ================= Notifications Feature Registration =================
  if (!getIt.isRegistered<NotificationRemoteDataSource>()) {
    getIt.registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSource(getIt<ApiClient>()),
    );
  }
  if (!getIt.isRegistered<NotificationRepository>()) {
    getIt.registerLazySingleton<NotificationRepository>(
      () => NotificationRepository(getIt<NotificationRemoteDataSource>()),
    );
  }
  if (!getIt.isRegistered<NotificationCubit>()) {
    getIt.registerFactory<NotificationCubit>(
      () => NotificationCubit(getIt<NotificationRepository>()),
    );
  }
}
