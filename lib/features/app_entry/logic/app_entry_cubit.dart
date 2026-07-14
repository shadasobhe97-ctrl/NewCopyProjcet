import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/driver/shared/di/driver_injection.dart';
import 'package:kids_transport/features/driver/driver_preferences/data/repositories/driver_preferences_repository.dart';

import 'app_entry_state.dart';

class AppEntryCubit extends Cubit<AppEntryState> {
  AppEntryCubit() : super(AppEntryInitial());

  Future<void> checkSession() async {
    await Future.delayed(const Duration(seconds: 2));

    if (StorageService.isFirstTime()) {
      emit(NavigateToOnboarding());
      return;
    }

    if (!StorageService.hasValidSession()) {
      emit(NavigateToLogin());
      return;
    }

    final roleId = StorageService.getRoleId();
    if (roleId == 4) {
      final isActive = StorageService.getIsActive() ?? false;
      if (isActive) {
        if (StorageService.getIsPreferencesSet()) {
          emit(NavigateToDriverHome());
          return;
        }
        try {
          final hasPrefs = await driverSl<DriverPreferencesRepository>().getPreferences();
          if (hasPrefs != null) {
            await StorageService.setIsPreferencesSet(true);
            emit(NavigateToDriverHome());
          } else {
            emit(NavigateToDriverPreferencesRequired());
          }
        } catch (_) {
          // Graceful fallback to avoid bricking if offline or API is down
          emit(NavigateToDriverHome());
        }
      } else {
        emit(NavigateToDriverWaiting());
      }
    } else if (roleId == 3) {
      emit(NavigateToParentHome());
    } else if (roleId != null && roleId != 3 && roleId != 4) {
      emit(NavigateToAdminHome());
    } else {
      await StorageService.clearSession();
      emit(NavigateToLogin());
    }
  }
}
