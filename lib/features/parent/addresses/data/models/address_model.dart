class AddressModel {
  final String? id;
  final int? parentId;
  final String label;
  final double lat;
  final double lng;
  final bool isDefault;

  AddressModel({
    this.id,
    this.parentId,
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

    // نستخدم toString() بدل as String? عشان ما تنكسر لو السيرفر رجّع
    // القيمة برقم أو بنوع غير متوقع
    final rawLabel = json['label'] ?? json['title'];

    final rawParentId = json['parent_id'];
    final parentId = rawParentId is int
        ? rawParentId
        : int.tryParse(rawParentId?.toString() ?? '');

    return AddressModel(
      id: json['id']?.toString(),
      parentId: parentId,
      label: rawLabel?.toString() ?? '',
      lat: parsedLat,
      lng: parsedLng,
      isDefault:
          json['is_default'] == true ||
          json['is_default'] == 1 ||
          json['is_default'].toString() == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (parentId != null) 'parent_id': parentId,
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
      'parent_id': parentId,
      'title': label,
      'latitude': lat,
      'longitude': lng,
      'is_default': isDefault,
      'details': '',
    };
  }
}
