class AuthCommonResponseModel {
  final bool status;
  final String message;

  AuthCommonResponseModel({
    required this.status,
    required this.message,
  });

  factory AuthCommonResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthCommonResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}