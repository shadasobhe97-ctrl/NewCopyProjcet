class EmployeeModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}
