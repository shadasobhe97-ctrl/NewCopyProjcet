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
      status: json['status'] ?? true,
      message: json['message'] ?? 'تم إنشاء الحساب بنجاح.',
      id: json['id'] ?? 0,
      accountId: json['account_id'] ?? 0,
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      alternativePhone: json['alternative_phone'],
      role: json['role'] ?? 'parent',
      isActive: json['is_active'] ?? true,
      accessToken: json['access_token'] ?? json['token'] ?? '',
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
      status: json['status'] ?? true,
      message: json['message'] ?? 'تم حفظ العنوان بنجاح.',
      id: json['id'] ?? 0,
      label: json['label'] ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['is_default'] ?? false,
    );
  }
}