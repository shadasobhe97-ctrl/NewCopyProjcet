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
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      userId: json['user_id'] ?? 0, // 🌟 المعرّف المهم للمرحلة الثالثة
    );
  }
}