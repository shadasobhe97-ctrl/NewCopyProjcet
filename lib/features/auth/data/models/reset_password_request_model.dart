class ResetPasswordRequestModel {
  final String email;
  final String code;
  final String password;
  final String passwordConfirmation;

  ResetPasswordRequestModel({
    required this.email,
    required this.code,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}