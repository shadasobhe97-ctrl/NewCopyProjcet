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
    // بعض APIs ترجع المستخدم داخل مفتاح 'user' (مثل الـ login/register)
    final data = (json['user'] is Map) ? Map<String, dynamic>.from(json['user'] as Map) : json;

    return ParentModel(
      // مطابقة المفاتيح مع رد الـ API الفعلي القادم من الباك
      parentId: _parseInt(data['parent_id'] ?? data['id'] ?? data['id_user']),
      userId: _parseInt(data['account_id'] ?? data['user_id'] ?? data['id_user']),
      fullName: (data['full_name'] ?? data['name'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      phoneNumber: (data['phone_number'] ?? '').toString(),
      alternativePhone: data['alternative_phone']?.toString(),
      avatarUrl: _resolvePhotoUrl(data['avatar_url']?.toString()),
      emailChangePending:
          data['email_change_pending'] == true ||
          data['email_change_pending'] == 1 ||
          data['email_change_pending'].toString() == '1',
    );
  }

  static String? _resolvePhotoUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://')) return 'https://${url.substring(7)}';
    return url;
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
