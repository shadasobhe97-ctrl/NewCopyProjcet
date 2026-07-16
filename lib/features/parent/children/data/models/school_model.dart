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
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'region': region, 'address': address};
  }
}
