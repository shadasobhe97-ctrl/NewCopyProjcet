import 'package:kids_transport/features/admin/data/models/admin_user_model.dart';

class AdminAuthState {
  final bool isLoading;
  final String? errorMessage;
  final AdminUserModel? currentUser;

  const AdminAuthState({
    this.isLoading = false,
    this.errorMessage,
    this.currentUser,
  });

  bool get isAuthenticated => currentUser != null;

  AdminAuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    AdminUserModel? currentUser,
    bool clearUser = false,
  }) {
    return AdminAuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      currentUser: clearUser ? null : currentUser ?? this.currentUser,
    );
  }
}
