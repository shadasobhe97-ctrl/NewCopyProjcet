class ParentRegisterResponse {
  final bool status;
  final String message;
  final ParentData data;
  final String token;

  ParentRegisterResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.token,
  });

  factory ParentRegisterResponse.fromJson(Map<String, dynamic> json) {
    return ParentRegisterResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      data: ParentData.fromJson(json['data'] ?? {}),
    );
  }
}

class ParentData {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;

  ParentData({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
  });

  factory ParentData.fromJson(Map<String, dynamic> json) {
    return ParentData(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      role: json['role'] ?? 'parent',
    );
  }
}