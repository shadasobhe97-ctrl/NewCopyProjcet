class DriverRegisterResponse {
  final bool status;
  final String message;
  final int userId;

  DriverRegisterResponse({
    required this.status,
    required this.message,
    required this.userId,
  });

  factory DriverRegisterResponse.fromJson(Map<String, dynamic> json) {
    return DriverRegisterResponse(
      status: _readBool(json['status']),
      message: json['message']?.toString() ?? '',
      userId: _readInt(json['user_id']), // 🌟 المعرّف المهم للمرحلة الثالثة
    );
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

bool _readBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}
