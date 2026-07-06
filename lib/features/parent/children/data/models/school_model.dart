class SchoolModel {
  final int id;
  final String name;
  final String region;
  final String address;

  SchoolModel({
    required this.id,
    required this.name,
    required this.region,
    required this.address,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'],
      name: json['name'],
      region: json['region'],
      address: json['address'],
    );
  }
}