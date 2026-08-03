class TripHistoryResponseModel {
  final int currentPage;
  final int perPage;
  final int total;
  final List<TripHistoryModel> data;

  const TripHistoryResponseModel({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.data,
  });

  bool get hasMore => currentPage * perPage < total;

  factory TripHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final payload = (json['data'] is Map)
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    return TripHistoryResponseModel(
      currentPage: _parseInt(payload['current_page']),
      perPage: _parseInt(payload['per_page'] ?? 15),
      total: _parseInt(payload['total']),
      data: (payload['data'] is List)
          ? (payload['data'] as List)
              .map((e) => TripHistoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : [],
    );
  }

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val != null) return int.tryParse(val.toString()) ?? 0;
    return 0;
  }
}

class TripHistoryDriver {
  final String name;

  const TripHistoryDriver({required this.name});

  factory TripHistoryDriver.fromJson(Map<String, dynamic> json) {
    return TripHistoryDriver(
      name: json['name']?.toString() ?? '',
    );
  }
}

class TripHistoryChild {
  final int childId;
  final String childName;
  final String schoolName;
  final String tripCost;
  final String? childPhoto;

  const TripHistoryChild({
    required this.childId,
    required this.childName,
    required this.schoolName,
    required this.tripCost,
    this.childPhoto,
  });

  factory TripHistoryChild.fromJson(Map<String, dynamic> json) {
    return TripHistoryChild(
      childId: _parseInt(json['child_id']),
      childName: json['child_name']?.toString() ?? '',
      schoolName: json['school_name']?.toString() ?? '',
      tripCost: json['trip_cost']?.toString() ?? '0.00',
      childPhoto: json['child_photo']?.toString() ?? json['photo']?.toString(),
    );
  }

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val != null) return int.tryParse(val.toString()) ?? 0;
    return 0;
  }
}

class TripHistoryPricing {
  final String totalTripCost;
  final String currency;

  const TripHistoryPricing({
    required this.totalTripCost,
    required this.currency,
  });

  factory TripHistoryPricing.fromJson(Map<String, dynamic> json) {
    return TripHistoryPricing(
      totalTripCost: json['total_trip_cost']?.toString() ?? '0.00',
      currency: json['currency']?.toString() ?? 'LYD',
    );
  }
}

class TripHistoryModel {
  final int tripId;
  final String tripType;
  final String tripDate;
  final TripHistoryDriver driver;
  final String actionType;
  final String scannedAt;
  final List<TripHistoryChild> children;
  final TripHistoryPricing pricing;

  const TripHistoryModel({
    required this.tripId,
    required this.tripType,
    required this.tripDate,
    required this.driver,
    required this.actionType,
    required this.scannedAt,
    required this.children,
    required this.pricing,
  });

  // UI Backward compatibility getters
  String get driverName => driver.name;
  String get direction =>
      (tripType.toLowerCase() == 'afternoon' || tripType.toLowerCase() == 'evening')
          ? 'to_home'
          : 'to_school';
  String get childName => children.isNotEmpty ? children.first.childName : '';
  String get pickupTime => scannedAt;
  String get dropoffTime => scannedAt;
  String get tripCost => pricing.totalTripCost;
  String get status => actionType;

  factory TripHistoryModel.fromJson(Map<String, dynamic> json) {
    return TripHistoryModel(
      tripId: _parseInt(json['trip_id'] ?? json['id']),
      tripType: json['trip_type']?.toString() ?? '',
      tripDate: json['trip_date']?.toString() ?? '',
      driver: TripHistoryDriver.fromJson(
        (json['driver'] is Map) ? Map<String, dynamic>.from(json['driver'] as Map) : {},
      ),
      actionType: json['action_type']?.toString() ?? '',
      scannedAt: json['scanned_at']?.toString() ?? '',
      children: (json['children'] is List)
          ? (json['children'] as List)
              .map((e) => TripHistoryChild.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : [],
      pricing: TripHistoryPricing.fromJson(
        (json['pricing'] is Map) ? Map<String, dynamic>.from(json['pricing'] as Map) : {},
      ),
    );
  }

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val != null) return int.tryParse(val.toString()) ?? 0;
    return 0;
  }
}
