import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/auth/login/data/repositories/session_repository.dart';
import 'package:kids_transport/features/driver/driver_preferences/data/repositories/driver_preferences_repository.dart';
import 'app_entry_state.dart';

class AppEntryCubit extends Cubit<AppEntryState> {
  final SessionRepository _sessionRepository;
  final DriverPreferencesRepository _driverPreferencesRepository;

  AppEntryCubit(this._sessionRepository, this._driverPreferencesRepository)
      : super(AppEntryInitial());

  Future<void> checkSession() async {
    await Future.delayed(const Duration(seconds: 2));

    if (_sessionRepository.isFirstTime()) {
      emit(NavigateToOnboarding());
      return;
    }

    if (!_sessionRepository.hasValidSession()) {
      emit(NavigateToLogin());
      return;
    }

    final roleId = _sessionRepository.getRoleId();
    if (roleId == 4) {
      final isActive = _sessionRepository.getIsActive() ?? false;
      if (isActive) {
        if (_sessionRepository.getIsPreferencesSet()) {
          emit(NavigateToDriverHome());
          return;
        }
        try {
          final prefs = await _driverPreferencesRepository.getPreferences();
          final hasPrefs = prefs != null;
          if (hasPrefs) {
            await _sessionRepository.setIsPreferencesSet(true);
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
      await _sessionRepository.clearSession();
      emit(NavigateToLogin());
    }
  }

  Future<void> completeOnboarding() async {
    await _sessionRepository.setFirstTimeComplete();
  }
}
