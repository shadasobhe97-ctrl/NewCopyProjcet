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

  factory ParentModel.fromJson(Map<String, dynamic> json) {
    return ParentModel(
      parentId: json['parent_id'] ?? json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      fullName: json['full_name'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      alternativePhone: json['alternative_phone'],
      avatarUrl: json['avatar_url'],
      emailChangePending: json['email_change_pending'] == true ||
          json['email_change_pending'] == 1 ||
          json['email_change_pending'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parent_id': parentId,
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'alternative_phone': alternativePhone,
      'avatar_url': avatarUrl,
      'email_change_pending': emailChangePending,
    };
  }
}
