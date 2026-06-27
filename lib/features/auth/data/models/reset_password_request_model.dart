class ResetPasswordRequestModel {
  final String email;
  final String password;
  final String passwordConfirmation;

  ResetPasswordRequestModel({
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}