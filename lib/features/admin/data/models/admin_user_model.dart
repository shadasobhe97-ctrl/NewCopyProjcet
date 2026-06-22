class AdminUserModel {
  final String id;
  final String name;
  final String email;
  final String token;

  AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
    };
  }
}
