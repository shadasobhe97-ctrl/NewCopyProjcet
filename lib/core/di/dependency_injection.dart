import 'package:get_it/get_it.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/features/parent/shared/di/parent_injection.dart';
import 'package:kids_transport/features/auth/shared/di/auth_injection.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  // ApiClient الموحد
  if (!getIt.isRegistered<ApiClient>()) {
    getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  }

  // تهيئة حقن المميزات
  initParentInjection();
  initAuthInjection();
}
