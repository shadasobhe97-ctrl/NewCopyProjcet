class SubscriptionLocationModel {
  final int? id;

  /// اسم الموقع: "منزلي" أو "مدرسة النور الابتدائية"
  final String? name;

  /// العنوان التفصيلي — قد يرجع كنص بديل من الخادم فيُعتبر فارغاً
  final String? address;
  final double? latitude;
  final double? longitude;

  const SubscriptionLocationModel({
    this.id,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
  });

  /// نصوص بديلة يرسلها الخادم بدل العنوان الحقيقي — لا تُعرض للمستخدم
  static const List<String> _placeholders = [
    'عنوان غير متوفر',
    'غير متوفر',
    'غير محدد',
    'null',
  ];

  static bool _isPlaceholder(String? v) {
    if (v == null) return true;
    final t = v.trim();
    return t.isEmpty || _placeholders.contains(t);
  }

  /// هل يوجد عنوان تفصيلي حقيقي يستحق العرض؟
  bool get hasRealAddress => !_isPlaceholder(address);

  /// هل يوجد اسم موقع؟
  bool get hasName => !_isPlaceholder(name);

  /// الاسم المعروض في العناوين الرئيسية (الاسم أولاً ثم العنوان)
  String get displayName {
    if (hasName) return name!.trim();
    if (hasRealAddress) return address!.trim();
    return 'غير محدد';
  }

  /// العنوان التفصيلي للعرض تحت الاسم.
  /// يرجع null إذا لم يوجد عنوان حقيقي، أو إذا كان نفسه الاسم المعروض
  /// (كي لا يتكرر السطر مرتين).
  String? get displayAddress {
    if (!hasRealAddress) return null;
    if (!hasName) return null; // العنوان صار هو الاسم المعروض
    final a = address!.trim();
    return a == name!.trim() ? null : a;
  }

  bool get hasValidCoordinates =>
      latitude != null &&
      longitude != null &&
      (latitude != 0.0 || longitude != 0.0);

  factory SubscriptionLocationModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionLocationModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? json['label']?.toString(),
      address: json['address']?.toString(),
      latitude: _parseDouble(json['latitude'] ?? json['lat']),
      longitude: _parseDouble(json['longitude'] ?? json['lng'] ?? json['long']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (address != null) 'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
