import 'package:kids_transport/features/auth/login/data/models/login_response_model.dart';

class ParentRegisterResponse {
  final bool status;
  final String message;
  final String accessToken;
  final String tokenType;
  final String roleName;
  final UserModel user;

  ParentRegisterResponse({
    required this.status,
    required this.message,
    required this.accessToken,
    required this.tokenType,
    required this.roleName,
    required this.user,
  });

  factory ParentRegisterResponse.fromJson(Map<String, dynamic> json) {
    final userMap = (json['user'] is Map)
        ? Map<String, dynamic>.from(json['user'] as Map)
        : <String, dynamic>{};

    return ParentRegisterResponse(
      status: _readBool(json['status']),
      message: json['message']?.toString() ?? 'تم إنشاء الحساب بنجاح.',
      accessToken: json['access_token']?.toString() ?? json['token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'Bearer',
      roleName: json['role_name']?.toString() ?? 'ولي أمر',
      user: UserModel.fromJson(userMap),
    );
  }

  int get id => user.id;
  int? get parentId => user.parentId;
  String get fullName => user.fullName;
  String get email => user.email ?? '';
  String get phoneNumber => user.phoneNumber;
  String? get alternativePhone => user.alternativePhone;
  String get role => user.role;
  bool get isActive => user.isActive;
}

class ParentAddressResponse {
  final bool status;
  final String message;
  final int id;
  final String label;
  final double lat;
  final double lng;
  final bool isDefault;

  ParentAddressResponse({
    required this.status,
    required this.message,
    required this.id,
    required this.label,
    required this.lat,
    required this.lng,
    required this.isDefault,
  });

  factory ParentAddressResponse.fromJson(Map<String, dynamic> json) {
    return ParentAddressResponse(
      status: _readBool(json['status']),
      message: json['message']?.toString() ?? 'تم حفظ العنوان بنجاح.',
      id: _readInt(json['id']),
      label: json['label']?.toString() ?? '',
      lat: _readDouble(json['lat']),
      lng: _readDouble(json['lng']),
      isDefault: _readBool(json['is_default']),
    );
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _readDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

bool _readBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}
