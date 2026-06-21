class LoginResponseModel {
  final bool status;
  final String message;
  final String accessToken;
  final String tokenType;
  final String roleName;
  final UserModel user;

  LoginResponseModel({
    required this.status,
    required this.message,
    required this.accessToken,
    required this.tokenType,
    required this.roleName,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      roleName: json['role_name'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}

class UserModel {
  final int id;
  final String fullName;
  final String phoneNumber;
  final int roleId;
  final bool isActive;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.roleId,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      roleId: json['role_id'] ?? 0,
      isActive: json['is_active'] ?? false,
    );
  }
}