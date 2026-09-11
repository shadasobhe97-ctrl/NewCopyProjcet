import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/services/notification_service.dart';
import 'package:kids_transport/core/services/storage_service.dart';
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

    // Save FCM Token in Firestore for valid active session
    final currentUserId = _sessionRepository.getUserId();
    if (currentUserId != null && currentUserId.isNotEmpty) {
      NotificationService.saveTokenToFirestore(currentUserId);
      NotificationService.syncDeviceTokenWithBackend();
    }

    final roleId = _sessionRepository.getRoleId();
    final roleName = _sessionRepository.getRoleName()?.toLowerCase().trim() ?? '';

    final isDriver = roleId == 8 ||
        roleId == 4 ||
        roleName.contains('driver') ||
        roleName.contains('سائق') ||
        roleName.contains('كابتن') ||
        roleName == '8' ||
        roleName == '4';

    final isParent = roleId == 7 ||
        roleId == 3 ||
        roleName.contains('parent') ||
        roleName.contains('guardian') ||
        roleName.contains('ولي') ||
        roleName == '7' ||
        roleName == '3';

    if (isDriver) {
      final regStage = _sessionRepository.getDriverRegStage();
      if (regStage == 'vehicle' || regStage == 'docs') {
        final draftData = _sessionRepository.getDriverRegDraft();
        emit(
          NavigateToResumeDriverRegistration(
            stage: regStage!,
            draftData: draftData,
          ),
        );
        return;
      }

      if (regStage == 'preferences') {
        emit(NavigateToDriverPreferencesRequired());
        return;
      }

      if (regStage == 'waiting') {
        emit(NavigateToDriverWaiting());
        return;
      }

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
          // إذا كان مفعل ولم يتم تأكيد حفظ التفضيلات محلياً، نوجّهه لإدخال التفضيلات
          emit(NavigateToDriverPreferencesRequired());
        }
      } else {
        emit(NavigateToDriverWaiting());
      }
    } else if (isParent) {
      final parentStage = StorageService.getParentRegStage();
      if (parentStage == 'location') {
        emit(NavigateToParentLocationRequired());
        return;
      } else if (parentStage == 'add_child' || parentStage == 'child') {
        emit(NavigateToParentChildRequired());
        return;
      }
      emit(NavigateToParentHome());
    } else {
      await _sessionRepository.clearSession();
      emit(NavigateToLogin());
    }
  }

  Future<void> completeOnboarding() async {
    await _sessionRepository.setFirstTimeComplete();
  }
}
