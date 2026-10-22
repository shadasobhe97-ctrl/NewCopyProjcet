class DriverAddressModel {
  final int id;
  final String label;
  final int? zoneId;
  final String? zoneName;
  final double lat;
  final double lng;

  const DriverAddressModel({
    required this.id,
    required this.label,
    this.zoneId,
    this.zoneName,
    required this.lat,
    required this.lng,
  });

  factory DriverAddressModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final parsedId = rawId is int
        ? rawId
        : (rawId != null ? int.tryParse(rawId.toString()) ?? 0 : 0);

    final rawZoneId = json['zone_id'] ?? json['zoneId'];
    final parsedZoneId = rawZoneId is int
        ? rawZoneId
        : (rawZoneId != null ? int.tryParse(rawZoneId.toString()) : null);

    final rawLat = json['lat'] ?? json['latitude'];
    final double parsedLat = rawLat is num
        ? rawLat.toDouble()
        : (double.tryParse(rawLat?.toString() ?? '') ?? 0.0);

    final rawLng = json['lng'] ?? json['longitude'];
    final double parsedLng = rawLng is num
        ? rawLng.toDouble()
        : (double.tryParse(rawLng?.toString() ?? '') ?? 0.0);

    return DriverAddressModel(
      id: parsedId,
      label: (json['label'] ?? json['title'] ?? '').toString(),
      zoneId: parsedZoneId,
      zoneName: json['zone_name']?.toString() ?? json['zoneName']?.toString(),
      lat: parsedLat,
      lng: parsedLng,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'label': label,
      'lat': lat,
      'lng': lng,
    };
    if (zoneId != null) {
      map['zone_id'] = zoneId;
    }
    return map;
  }

  DriverAddressModel copyWith({
    int? id,
    String? label,
    int? zoneId,
    String? zoneName,
    double? lat,
    double? lng,
  }) {
    return DriverAddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}
