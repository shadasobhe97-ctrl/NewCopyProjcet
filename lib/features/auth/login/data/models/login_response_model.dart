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
      status: _readBool(json['status']),
      message: json['message']?.toString() ?? '',
      accessToken: json['access_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'Bearer',
      roleName: json['role_name']?.toString() ?? '',
      user: UserModel.fromJson(_readMap(json['user'])),
    );
  }

  bool get isParent => user.roleId == 3;
  bool get isDriver => user.roleId == 4;
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
      id: _readInt(json['id']),
      fullName: json['full_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      roleId: _readInt(json['role_id']),
      isActive: _readBool(json['is_active']),
    );
  }
}

Map<String, dynamic> _readMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
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
