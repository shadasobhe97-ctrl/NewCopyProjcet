class ParentModel {
  final int parentId;
  final int userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? alternativePhone;
  final String? avatarUrl;
  final bool emailChangePending;

  ParentModel({
    required this.parentId,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.alternativePhone,
    this.avatarUrl,
    required this.emailChangePending,
  });

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  factory ParentModel.fromJson(Map<String, dynamic> json) {
    return ParentModel(
      // مطابقة المفاتيح مع رد الـ API الفعلي القادم من الباك
      parentId: _parseInt(json['id'] ?? json['parent_id']),
      userId: _parseInt(json['account_id'] ?? json['user_id']),
      fullName: (json['full_name'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber: (json['phone_number'] ?? '').toString(),
      alternativePhone: json['alternative_phone']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      emailChangePending:
          json['email_change_pending'] == true ||
          json['email_change_pending'] == 1 ||
          json['email_change_pending'].toString() == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': parentId,
      'account_id': userId,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'alternative_phone': alternativePhone,
      'avatar_url': avatarUrl,
      'email_change_pending': emailChangePending,
    };
  }
}
