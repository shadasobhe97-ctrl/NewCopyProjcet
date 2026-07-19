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
  final int? parentId;
  final int? driverId;
  final String fullName;
  final String? email;
  final String phoneNumber;
  final String? alternativePhone;
  final int roleId;
  final String role;
  final bool isActive;
  final bool? isTrusted;
  final String? avatarUrl;
  final bool? emailChangePending;

  UserModel({
    required this.id,
    this.parentId,
    this.driverId,
    required this.fullName,
    this.email,
    required this.phoneNumber,
    this.alternativePhone,
    required this.roleId,
    required this.role,
    required this.isActive,
    this.isTrusted,
    this.avatarUrl,
    this.emailChangePending,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final id = _readInt(json['id_user'] ?? json['id'] ?? json['user_id']);
    final role = json['role']?.toString() ?? 'parent';
    final roleId = _roleToId(role);

    final rawParentId = json['parent_id'];
    final parentId = rawParentId is int
        ? rawParentId
        : int.tryParse(rawParentId?.toString() ?? '');

    final rawDriverId = json['driver_id'];
    final driverId = rawDriverId is int
        ? rawDriverId
        : int.tryParse(rawDriverId?.toString() ?? '');

    return UserModel(
      id: id,
      parentId: parentId,
      driverId: driverId,
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString() ?? '',
      alternativePhone: json['alternative_phone']?.toString(),
      roleId: roleId,
      role: role,
      isActive: _readBool(json['is_active']),
      isTrusted: json['is_trusted'] == true,
      avatarUrl: json['avatar_url']?.toString(),
      emailChangePending: json['email_change_pending'] == true,
    );
  }

  static int _roleToId(String role) {
    switch (role.toLowerCase()) {
      case 'parent':
        return 3;
      case 'driver':
        return 4;
      case 'admin':
        return 1;
      default:
        return 0;
    }
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
