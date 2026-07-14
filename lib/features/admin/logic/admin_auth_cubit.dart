import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/admin/data/models/admin_user_model.dart';
import 'package:kids_transport/features/auth/login/data/models/login_request_model.dart';
import 'package:kids_transport/features/auth/login/data/repositories/auth_repository.dart';
import 'admin_auth_state.dart';

export 'admin_auth_state.dart';

class AdminAuthCubit extends Cubit<AdminAuthState> {
  final AuthRepository _repository;

  AdminAuthCubit(this._repository) : super(_initialState());

  bool get isLoading => state.isLoading;
  String? get errorMessage => state.errorMessage;
  AdminUserModel? get currentUser => state.currentUser;
  bool get isAuthenticated => state.isAuthenticated;

  static AdminAuthState _initialState() {
    final token = StorageService.getToken();
    final roleId = StorageService.getRoleId();
    final fullName = StorageService.getFullName();
    final phone = StorageService.getPhoneNumber();

    if (token != null && roleId != null && roleId != 3 && roleId != 4) {
      return AdminAuthState(
        currentUser: AdminUserModel(
          id: StorageService.getUserId()?.toString() ?? '',
          name: fullName ?? 'ط§ظ„ظ…ط³ط¤ظˆظ„',
          email: phone ?? '',
          token: token,
        ),
      );
    }

    return const AdminAuthState();
  }

  Future<bool> login(String phone, String password) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final response = await _repository.login(
        LoginRequestModel(
          phoneNumber: phone,
          password: password,
          deviceName: _deviceName,
          platform: _platform,
        ),
      );

      if (!response.status) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: _fallbackMessage(
              response.message,
              'ط¨ظٹط§ظ†ط§طھ ط§ظ„ط¯ط®ظˆظ„ ط؛ظٹط± طµط­ظٹط­ط©',
            ),
          ),
        );
        return false;
      }

      if (!_isAdminRole(response.user.roleId)) {
        await StorageService.clearSession();
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'ظ‡ط°ط§ ط§ظ„ط­ط³ط§ط¨ ظ„ظٹط³ ط­ط³ط§ط¨ ظ…ط³ط¤ظˆظ„.',
            clearUser: true,
          ),
        );
        return false;
      }

      emit(
        state.copyWith(
          isLoading: false,
          clearError: true,
          currentUser: AdminUserModel(
            id: response.user.id.toString(),
            name: response.user.fullName,
            email: response.user.phoneNumber.isNotEmpty
                ? response.user.phoneNumber
                : phone,
            token: response.accessToken,
          ),
        ),
      );

      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'ط­ط¯ط« ط®ط·ط£ ظپظٹ ط§ظ„ط§طھطµط§ظ„ ط¨ط§ظ„ط®ط§ط¯ظ…',
        ),
      );
      return false;
    }
  }

  Future<bool> logout() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final response = await _repository.logout();
      if (!response.status) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: _fallbackMessage(
              response.message,
              'ظپط´ظ„ طھط³ط¬ظٹظ„ ط§ظ„ط®ط±ظˆط¬.',
            ),
          ),
        );
        return false;
      }

      emit(state.copyWith(isLoading: false, clearUser: true, clearError: true));
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage:
              'ظپط´ظ„ طھط³ط¬ظٹظ„ ط§ظ„ط®ط±ظˆط¬طŒ ظٹط±ط¬ظ‰ ط§ظ„ظ…ط­ط§ظˆظ„ط© ظ…ط±ط© ط£ط®ط±ظ‰.',
        ),
      );
      return false;
    } finally {
      await StorageService.clearSession();
      emit(state.copyWith(isLoading: false, clearUser: true));
    }
  }

  bool _isAdminRole(int roleId) => roleId > 0 && roleId != 3 && roleId != 4;

  String get _platform => kIsWeb ? 'web' : defaultTargetPlatform.name;

  String get _deviceName {
    if (kIsWeb) return 'Web_Admin_Panel';
    return 'Derbi_Admin_${defaultTargetPlatform.name}';
  }

  String _fallbackMessage(String message, String fallback) {
    return message.trim().isNotEmpty ? message : fallback;
  }
}
