class AuthCommonResponseModel {
  final bool status;
  final String message;

  const AuthCommonResponseModel({
    required this.status,
    required this.message,
  });

  factory AuthCommonResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthCommonResponseModel(
      status: _readBool(json['status']),
      message: json['message']?.toString() ?? '',
    );
  }
}

bool _readBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}
