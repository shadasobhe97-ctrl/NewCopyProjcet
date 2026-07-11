class AddressModel {
  final String? id;
  final String label;
  final double lat;
  final double lng;
  final String? addressDetails;
  final bool isDefault;

  AddressModel({
    this.id,
    required this.label,
    required this.lat,
    required this.lng,
    this.addressDetails,
    this.isDefault = false,
  });

  // UI Getters for compatibility
  String get title => label;
  double get latitude => lat;
  double get longitude => lng;

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString(),
      label: json['label'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      addressDetails: json['address_details'] as String?,
      isDefault: (json['is_default'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'lat': lat,
      'lng': lng,
      'is_default': isDefault,
      if (addressDetails != null && addressDetails!.isNotEmpty)
        'address_details': addressDetails,
    };
  }

  /// تحويل من Map للتوافق مع AddressCard الحالية
  Map<String, dynamic> toDisplayMap() {
    return {
      'id': id,
      'title': label,
      'latitude': lat,
      'longitude': lng,
      'is_default': isDefault,
      'details': addressDetails ?? '',
    };
  }
}