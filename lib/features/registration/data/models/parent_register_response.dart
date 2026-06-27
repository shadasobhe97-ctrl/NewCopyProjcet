class ParentRegisterResponse {
  final bool status;
  final String message;
  final int id;
  final int accountId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? alternativePhone;
  final String role;
  final bool isActive;
  final String accessToken;

  ParentRegisterResponse({
    required this.status,
    required this.message,
    required this.id,
    required this.accountId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.alternativePhone,
    required this.role,
    required this.isActive,
    required this.accessToken,
  });

  factory ParentRegisterResponse.fromJson(Map<String, dynamic> json) {
    return ParentRegisterResponse(
      status: _readBool(json['status']),
      message: json['message']?.toString() ?? 'تم إنشاء الحساب بنجاح.',
      id: _readInt(json['id']),
      accountId: _readInt(json['account_id']),
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      alternativePhone: json['alternative_phone']?.toString(),
      role: json['role']?.toString() ?? 'parent',
      isActive: _readBool(json['is_active']),
      accessToken: json['access_token']?.toString() ?? json['token']?.toString() ?? '',
    );
  }
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
