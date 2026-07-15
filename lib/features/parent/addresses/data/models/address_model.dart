class AddressModel {
  final String? id;
  final String label;
  final double lat;
  final double lng;
  final bool isDefault;

  AddressModel({
    this.id,
    required this.label,
    required this.lat,
    required this.lng,
    this.isDefault = false,
  });

  // UI Getters for compatibility
  String get title => label;
  double get latitude => lat;
  double get longitude => lng;

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    final rawLat = json['lat'] ?? json['latitude'];
    final rawLng = json['lng'] ?? json['longitude'];
    
    double parsedLat = 0.0;
    if (rawLat != null) {
      if (rawLat is num) {
        parsedLat = rawLat.toDouble();
      } else {
        parsedLat = double.tryParse(rawLat.toString()) ?? 0.0;
      }
    }

    double parsedLng = 0.0;
    if (rawLng != null) {
      if (rawLng is num) {
        parsedLng = rawLng.toDouble();
      } else {
        parsedLng = double.tryParse(rawLng.toString()) ?? 0.0;
      }
    }

    return AddressModel(
      id: json['id']?.toString(),
      label: json['label'] as String? ?? json['title'] as String? ?? '',
      lat: parsedLat,
      lng: parsedLng,
      isDefault: json['is_default'] == true ||
          json['is_default'] == 1 ||
          json['is_default'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'lat': lat,
      'lng': lng,
      'is_default': isDefault,
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
      'details': '',
    };
  }
}