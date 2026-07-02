class AddressModel {
  final String? id;
  final String title; // مثل: المنزل الرئيسي، بيت الجد
  final double latitude;
  final double longitude;
  final String? addressDetails;

  AddressModel({
    this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    this.addressDetails,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      title: json['title'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      addressDetails: json['address_details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'latitude': latitude,
      'longitude': longitude,
      'address_details': addressDetails,
    };
  }
}