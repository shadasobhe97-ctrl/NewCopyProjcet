import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/services/storage_service.dart';

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
        emit(NavigateToDriverHome());
      } else {
        emit(NavigateToDriverWaiting());
      }
    } else if (roleId == 3) {
      emit(NavigateToParentHome());
    } else if (roleId == 1 || roleId == 2) {
      emit(NavigateToAdminHome());
    } else {
      await StorageService.clearSession();
      emit(NavigateToLogin());
    }
  }
}
