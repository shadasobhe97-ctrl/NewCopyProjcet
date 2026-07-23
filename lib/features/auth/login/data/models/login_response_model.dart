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
    final userMap = _readMap(json['user']);
    final user = UserModel.fromJson(userMap.isNotEmpty ? userMap : json);

    final rawRoleName = json['role_name']?.toString() ??
        json['roleName']?.toString() ??
        json['role']?.toString() ??
        user.role;

    int roleId = _readInt(json['role_id'] ?? json['roleId']);
    if (roleId == 0) {
      roleId = user.roleId;
    }
    if (roleId == 0) {
      roleId = UserModel._roleToId(rawRoleName);
    }

    final finalUser = user.roleId != roleId
        ? UserModel(
            id: user.id,
            parentId: user.parentId,
            driverId: user.driverId,
            fullName: user.fullName,
            email: user.email,
            phoneNumber: user.phoneNumber,
            alternativePhone: user.alternativePhone,
            roleId: roleId,
            role: user.role,
            isActive: user.isActive,
            isTrusted: user.isTrusted,
            avatarUrl: user.avatarUrl,
            emailChangePending: user.emailChangePending,
          )
        : user;

    return LoginResponseModel(
      status: _readBool(json['status'] ?? json['success']),
      message: json['message']?.toString() ?? '',
      accessToken: json['access_token']?.toString() ?? json['token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'Bearer',
      roleName: rawRoleName.isNotEmpty ? rawRoleName : (roleId == 4 ? 'driver' : 'parent'),
      user: finalUser,
    );
  }

  bool get isParent => user.roleId == 3 || UserModel._roleToId(roleName) == 3 || roleName.toLowerCase().contains('parent') || roleName.contains('ولي');
  bool get isDriver => user.roleId == 4 || UserModel._roleToId(roleName) == 4 || roleName.toLowerCase().contains('driver') || roleName.contains('سائق');
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
    final rawRole = json['role']?.toString() ??
        json['role_name']?.toString() ??
        json['roleName']?.toString() ??
        json['name_role']?.toString() ??
        '';

    final rawRoleId = _readInt(json['role_id'] ?? json['roleId'] ?? json['id_role'] ?? 0);
    int roleId = rawRoleId;
    if (roleId == 0 || (roleId != 3 && roleId != 4 && roleId != 1)) {
      roleId = _roleToId(rawRole);
    }
    if (roleId == 0 && rawRoleId > 0) {
      roleId = rawRoleId;
    }

    final rawParentId = json['parent_id'] ?? json['parentId'];
    final parentId = rawParentId is int
        ? rawParentId
        : int.tryParse(rawParentId?.toString() ?? '');

    final rawDriverId = json['driver_id'] ?? json['driverId'];
    final driverId = rawDriverId is int
        ? rawDriverId
        : int.tryParse(rawDriverId?.toString() ?? '');

    return UserModel(
      id: id,
      parentId: parentId,
      driverId: driverId,
      fullName: json['full_name']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString() ?? json['phone']?.toString() ?? '',
      alternativePhone: json['alternative_phone']?.toString() ?? json['alternative_phone_number']?.toString(),
      roleId: roleId,
      role: rawRole.isNotEmpty ? rawRole : (roleId == 4 ? 'driver' : 'parent'),
      isActive: _readBool(json['is_active'] ?? json['isActive'] ?? true),
      isTrusted: json['is_trusted'] == true,
      avatarUrl: json['avatar_url']?.toString() ?? json['photo_url']?.toString(),
      emailChangePending: json['email_change_pending'] == true,
    );
  }

  static int _roleToId(String role) {
    final r = role.toLowerCase().trim();
    if (r == '4' || r.contains('driver') || r.contains('سائق') || r.contains('كابتن')) {
      return 4;
    }
    if (r == '3' || r.contains('parent') || r.contains('guardian') || r.contains('ولي')) {
      return 3;
    }
    if (r == '1' || r.contains('admin') || r.contains('أدمن') || r.contains('مدير')) {
      return 1;
    }
    return int.tryParse(r) ?? 0;
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
