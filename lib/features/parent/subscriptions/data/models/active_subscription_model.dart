// نموذج الاشتراك النشط - GET /api/parent/active-subscriptions
// الـ response مختلف تماماً عن SubscriptionModel

class ActiveSubscriptionModel {
  final int id;
  final String status; // active | pending_start | completed | cancelled
  final String? statusLabel;
  final String? pickupTime;
  final String? dropoffTime;
  final Location? pickupLocation;
  final Location? dropoffLocation;
  final ActiveChild child;
  final ActiveContract contract;
  final ActiveDriver driver;
  final String createdAt;

  const ActiveSubscriptionModel({
    required this.id,
    required this.status,
    this.statusLabel,
    this.pickupTime,
    this.dropoffTime,
    this.pickupLocation,
    this.dropoffLocation,
    required this.child,
    required this.contract,
    required this.driver,
    required this.createdAt,
  });

  String get statusDisplayLabel {
    if (statusLabel != null && statusLabel!.isNotEmpty) {
      return statusLabel!;
    }
    switch (status.toLowerCase()) {
      case 'active':
        return 'نشط';
      case 'pending_start':
      case 'pending':
        return 'بانتظار البدء';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  String get formattedPrice {
    final tp = contract.totalPrice;
    if (tp == tp.toInt()) {
      return '${tp.toInt()} دينار';
    }
    return '${tp.toStringAsFixed(2)} دينار';
  }

  String get childName => child.name ?? child.schoolName;

  factory ActiveSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return ActiveSubscriptionModel(
      id: _parseInt(json['id']) ?? 0,
      status: json['status']?.toString() ?? 'active',
      statusLabel: json['statusLabel']?.toString() ?? json['status_label']?.toString(),
      pickupTime: json['pickup_time']?.toString(),
      dropoffTime: json['dropoff_time']?.toString(),
      pickupLocation: json['pickup_location'] is Map
          ? Location.fromJson(
              Map<String, dynamic>.from(json['pickup_location'] as Map))
          : null,
      dropoffLocation: json['dropoff_location'] is Map
          ? Location.fromJson(
              Map<String, dynamic>.from(json['dropoff_location'] as Map))
          : null,
      child: ActiveChild.fromJson(
        json['child'] as Map<String, dynamic>? ?? {},
      ),
      contract: ActiveContract.fromJson(
        (json['contract'] ?? json['billing']) as Map<String, dynamic>? ?? {},
      ),
      driver: ActiveDriver.fromJson(
        json['driver'] as Map<String, dynamic>? ?? {},
      ),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        if (statusLabel != null) 'statusLabel': statusLabel,
        if (pickupTime != null) 'pickup_time': pickupTime,
        if (dropoffTime != null) 'dropoff_time': dropoffTime,
        if (pickupLocation != null) 'pickup_location': pickupLocation!.toJson(),
        if (dropoffLocation != null)
          'dropoff_location': dropoffLocation!.toJson(),
        'child': child.toJson(),
        'contract': contract.toJson(),
        'driver': driver.toJson(),
        'created_at': createdAt,
      };
}

// ── الموقع ──
class Location {
  final double latitude;
  final double longitude;
  final String? label;

  const Location({
    required this.latitude,
    required this.longitude,
    this.label,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        latitude: _parseDouble(json['latitude']) ?? 0.0,
        longitude: _parseDouble(json['longitude']) ?? 0.0,
        label: json['label']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (label != null) 'label': label,
      };
}

// ── الطفل (واحد فقط، ليس مصفوفة) ──
class ActiveChild {
  final int id;
  final String? name;
  final String schoolName;

  const ActiveChild({
    required this.id,
    this.name,
    required this.schoolName,
  });

  factory ActiveChild.fromJson(Map<String, dynamic> json) => ActiveChild(
        id: _parseInt(json['id']) ?? 0,
        name: json['name']?.toString() ?? json['child_name']?.toString() ?? json['childName']?.toString(),
        schoolName: json['school_name']?.toString() ?? json['schoolName']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (name != null) 'name': name,
        'school_name': schoolName,
      };
}

// ── العقد ──
class ActiveContract {
  final int id;
  final String contractNumber;
  final String startDate;
  final String endDate;
  final double totalPrice;
  final String status;

  const ActiveContract({
    required this.id,
    required this.contractNumber,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
  });

  factory ActiveContract.fromJson(Map<String, dynamic> json) => ActiveContract(
        id: _parseInt(json['id']) ?? 0,
        contractNumber: json['contract_number']?.toString() ?? json['contractNumber']?.toString() ?? '',
        startDate: json['start_date']?.toString() ?? json['startDate']?.toString() ?? json['startsAt']?.toString() ?? json['starts_at']?.toString() ?? '',
        endDate: json['end_date']?.toString() ?? json['endDate']?.toString() ?? json['endsAt']?.toString() ?? json['ends_at']?.toString() ?? '',
        totalPrice: _parseDouble(json['total_price']) ?? _parseDouble(json['totalPrice']) ?? 0.0,
        status: json['status']?.toString() ?? 'active',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'contract_number': contractNumber,
        'start_date': startDate,
        'end_date': endDate,
        'total_price': totalPrice,
        'status': status,
      };
}

// ── السائق مع المركبة ──
class ActiveDriver {
  final int id;
  final String name;
  final String? phone;
  final String? avatarUrl;
  final ActiveVehicle? vehicle;

  const ActiveDriver({
    required this.id,
    required this.name,
    this.phone,
    this.avatarUrl,
    this.vehicle,
  });

  factory ActiveDriver.fromJson(Map<String, dynamic> json) => ActiveDriver(
        id: _parseInt(json['id']) ?? 0,
        name: json['name']?.toString() ?? '',
        phone: json['phone']?.toString(),
        avatarUrl: json['avatar_url']?.toString() ?? json['avatar']?.toString() ?? json['avatarUrl']?.toString(),
        vehicle: json['vehicle'] is Map
            ? ActiveVehicle.fromJson(
                Map<String, dynamic>.from(json['vehicle'] as Map))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (phone != null) 'phone': phone,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (vehicle != null) 'vehicle': vehicle!.toJson(),
      };
}

// ── المركبة ──
class ActiveVehicle {
  final String plateNumber;
  final String? brand;
  final String? model;
  final String? color;

  const ActiveVehicle({
    required this.plateNumber,
    this.brand,
    this.model,
    this.color,
  });

  factory ActiveVehicle.fromJson(Map<String, dynamic> json) => ActiveVehicle(
        plateNumber: json['plate_number']?.toString() ?? '',
        brand: json['brand']?.toString(),
        model: json['model']?.toString(),
        color: json['color']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'plate_number': plateNumber,
        if (brand != null) 'brand': brand,
        if (model != null) 'model': model,
        if (color != null) 'color': color,
      };

  String get displayName =>
      [brand, model, color].where((e) => e != null && e.isNotEmpty).join(' ');
}

// ─────────────────────────────────────────────
// Private helper functions for safe JSON parsing
// ─────────────────────────────────────────────

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

double? _parseDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}
