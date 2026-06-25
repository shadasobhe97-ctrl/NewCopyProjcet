abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// كلاس النجاح الموحد والديناميكي الجاهز للربط بالباكيند 100%
class AuthSuccess extends AuthState {
  final String message;
  final String roleName;
  final String token; // التوكن يمر ديناميكياً هنا
  final int roleId;
  const AuthSuccess({
    required this.message, 
    required this.roleName, 
    required this.token,
    required this.roleId,
  });
}

class AuthError extends AuthState {
  final String errorMessage;
  const AuthError(this.errorMessage);
}

class PasswordVisibilityChanged extends AuthState {
  final bool isObscured;
  const PasswordVisibilityChanged(this.isObscured);
}

class OtpSentSuccess extends AuthState {
  final String message;
  final String email;
  const OtpSentSuccess({required this.message, required this.email});
}

class PasswordResetSuccessState extends AuthState {
  final String message;
  const PasswordResetSuccessState(this.message);
}

class AuthLogoutSuccess extends AuthState {
  final String message;
  const AuthLogoutSuccess(this.message);
}
