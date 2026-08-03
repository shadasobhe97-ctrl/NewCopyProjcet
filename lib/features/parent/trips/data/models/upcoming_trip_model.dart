import 'active_trip_model.dart';

class UpcomingTripDriver {
  final String name;

  const UpcomingTripDriver({required this.name});

  factory UpcomingTripDriver.fromJson(Map<String, dynamic> json) {
    return UpcomingTripDriver(
      name: json['name']?.toString() ?? '',
    );
  }
}

class UpcomingTripDestination {
  final String type;
  final String name;

  const UpcomingTripDestination({
    required this.type,
    required this.name,
  });

  factory UpcomingTripDestination.fromJson(Map<String, dynamic> json) {
    return UpcomingTripDestination(
      type: json['type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class UpcomingTripChild {
  final int childId;
  final String childName;
  final String schoolName;
  final String? childPhoto;

  const UpcomingTripChild({
    required this.childId,
    required this.childName,
    required this.schoolName,
    this.childPhoto,
  });

  factory UpcomingTripChild.fromJson(Map<String, dynamic> json) {
    return UpcomingTripChild(
      childId: _parseInt(json['child_id']),
      childName: json['child_name']?.toString() ?? '',
      schoolName: json['school_name']?.toString() ?? '',
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

class UpcomingTripPricing {
  final String totalTripCost;
  final String costPerChild;
  final String currency;

  const UpcomingTripPricing({
    required this.totalTripCost,
    required this.costPerChild,
    required this.currency,
  });

  factory UpcomingTripPricing.fromJson(Map<String, dynamic> json) {
    return UpcomingTripPricing(
      totalTripCost: json['total_trip_cost']?.toString() ?? '0.00',
      costPerChild: json['cost_per_child']?.toString() ?? '0.00',
      currency: json['currency']?.toString() ?? 'LYD',
    );
  }
}

class UpcomingTripModel {
  final int tripId;
  final String tripType;
  final String title;
  final String scheduledFor;
  final UpcomingTripDriver driver;
  final UpcomingTripDestination destination;
  final List<UpcomingTripChild> children;
  final int totalChildren;
  final UpcomingTripPricing pricing;

  const UpcomingTripModel({
    required this.tripId,
    required this.tripType,
    required this.title,
    required this.scheduledFor,
    required this.driver,
    required this.destination,
    required this.children,
    required this.totalChildren,
    required this.pricing,
  });

  // UI Backward compatibility getters
  String get direction =>
      (tripType.toLowerCase() == 'afternoon' || tripType.toLowerCase() == 'evening')
          ? 'to_home'
          : 'to_school';
  String get driverName => driver.name;
  String get schoolName => destination.name;
  String get childName => children.isNotEmpty ? children.first.childName : '';
  String get scheduledDate => scheduledFor;
  String get scheduledTime => '';
  VehicleInfoModel get vehicle => const VehicleInfoModel(info: 'حافلة مدرسية');

  factory UpcomingTripModel.fromJson(Map<String, dynamic> json) {
    return UpcomingTripModel(
      tripId: _parseInt(json['trip_id'] ?? json['id']),
      tripType: json['trip_type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      scheduledFor: json['scheduled_for']?.toString() ?? '',
      driver: UpcomingTripDriver.fromJson(
        (json['driver'] is Map) ? Map<String, dynamic>.from(json['driver'] as Map) : {},
      ),
      destination: UpcomingTripDestination.fromJson(
        (json['destination'] is Map) ? Map<String, dynamic>.from(json['destination'] as Map) : {},
      ),
      children: (json['children'] is List)
          ? (json['children'] as List)
              .map((e) => UpcomingTripChild.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : [],
      totalChildren: _parseInt(
        json['total_children'] ??
            (json['children'] is List ? (json['children'] as List).length : 0),
      ),
      pricing: UpcomingTripPricing.fromJson(
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
