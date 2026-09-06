class AddressModel {
  final String? id;
  final String title;
  final String? streetAddress;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final int? zoneId;
  final String? zoneName;
  final String? createdAt;

  AddressModel({
    this.id,
    String? title,
    String? label,
    this.streetAddress,
    double? latitude,
    double? lat,
    double? longitude,
    double? lng,
    this.isDefault = false,
    this.zoneId,
    this.zoneName,
    this.createdAt,
    @Deprecated('user_id is no longer required') int? userId,
  })  : title = title ?? label ?? '',
        latitude = latitude ?? lat ?? 0.0,
        longitude = longitude ?? lng ?? 0.0;

  // Compatibility getters
  String get label => title;
  double get lat => latitude;
  double get lng => longitude;

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    final rawLat = json['latitude'] ?? json['lat'];
    final rawLng = json['longitude'] ?? json['lng'];

    double parsedLat = 0.0;
    if (rawLat != null) {
      parsedLat = rawLat is num
          ? rawLat.toDouble()
          : double.tryParse(rawLat.toString()) ?? 0.0;
    }

    double parsedLng = 0.0;
    if (rawLng != null) {
      parsedLng = rawLng is num
          ? rawLng.toDouble()
          : double.tryParse(rawLng.toString()) ?? 0.0;
    }

    final rawTitle = json['title'] ?? json['label'];
    final rawStreet = json['street_address'] ?? json['streetAddress'];
    final rawZoneId = json['zone_id'] ?? json['zoneId'];
    final rawZoneName = json['zone_name'] ?? json['zoneName'];
    final rawCreatedAt = json['created_at'] ?? json['createdAt'];

    final zoneId = rawZoneId is int
        ? rawZoneId
        : int.tryParse(rawZoneId?.toString() ?? '');

    return AddressModel(
      id: json['id']?.toString(),
      title: rawTitle?.toString() ?? '',
      streetAddress: rawStreet?.toString(),
      latitude: parsedLat,
      longitude: parsedLng,
      isDefault: json['is_default'] == true ||
          json['is_default'] == 1 ||
          json['is_default'].toString() == '1',
      zoneId: zoneId,
      zoneName: rawZoneName?.toString(),
      createdAt: rawCreatedAt?.toString(),
    );
  }

  /// يطابق Backend API Contract بدقة (POST /api/parent/addresses)
  /// بدون parent_id / parentId / user_id
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (streetAddress != null && streetAddress!.isNotEmpty)
        'street_address': streetAddress,
      'latitude': latitude,
      'longitude': longitude,
      if (zoneId != null) 'zone_id': zoneId,
      'is_default': isDefault,
    };
  }

  /// تحويل لـ Map للتوافق مع شاشات العرض والتخزين المحلي
  Map<String, dynamic> toDisplayMap() {
    return {
      'id': id,
      'title': title,
      'street_address': streetAddress,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
      'zone_id': zoneId,
      'zone_name': zoneName,
      'created_at': createdAt,
    };
  }
}
