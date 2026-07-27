class SubscriptionDetailModel {
  final int id;
  final String status;
  final String statusLabel;
  final DetailChild child;
  final DetailDriver driver;
  final DetailSchedule schedule;
  final DetailBilling billing;
  final int requestId;
  final String? cancelReason;
  final String? cancelledAt;
  final String createdAt;

  const SubscriptionDetailModel({
    required this.id,
    required this.status,
    required this.statusLabel,
    required this.child,
    required this.driver,
    required this.schedule,
    required this.billing,
    required this.requestId,
    this.cancelReason,
    this.cancelledAt,
    required this.createdAt,
  });

  String get statusDisplayLabel {
    switch (status.toLowerCase()) {
      case 'active':
        return 'نشط';
      case 'pending_start':
        return 'بانتظار البدء';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return statusLabel.isNotEmpty ? statusLabel : status;
    }
  }

  factory SubscriptionDetailModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionDetailModel(
        id: _parseInt(json['id']) ?? 0,
        status: json['status']?.toString() ?? '',
        statusLabel: json['statusLabel']?.toString() ?? json['status_label']?.toString() ?? '',
        child: DetailChild.fromJson(json['child'] as Map<String, dynamic>? ?? {}),
        driver: DetailDriver.fromJson(json['driver'] as Map<String, dynamic>? ?? {}),
        schedule: DetailSchedule.fromJson((json['schedule'] ?? json) as Map<String, dynamic>),
        billing: DetailBilling.fromJson((json['billing'] ?? json['contract'] ?? json) as Map<String, dynamic>),
        requestId: _parseInt(json['requestId'] ?? json['request_id'] ?? json['id']) ?? 0,
        cancelReason: json['cancelReason']?.toString() ?? json['cancel_reason']?.toString(),
        cancelledAt: json['cancelledAt']?.toString() ?? json['cancelled_at']?.toString(),
        createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '',
      );
}

class DetailChild {
  final int id;
  final String? name;
  final String? avatar;
  final String? avatarInitials;
  final String schoolName;
  final DetailLocation? schoolLocation;

  const DetailChild({
    required this.id,
    this.name,
    this.avatar,
    this.avatarInitials,
    required this.schoolName,
    this.schoolLocation,
  });

  factory DetailChild.fromJson(Map<String, dynamic> json) => DetailChild(
        id: _parseInt(json['id']) ?? 0,
        name: json['name']?.toString() ?? json['child_name']?.toString() ?? json['childName']?.toString(),
        avatar: json['avatar']?.toString() ?? json['photo_url']?.toString() ?? json['image']?.toString(),
        avatarInitials: json['avatarInitials']?.toString() ?? json['avatar_initials']?.toString(),
        schoolName: json['schoolName']?.toString() ?? json['school_name']?.toString() ?? '',
        schoolLocation: json['schoolLocation'] is Map
            ? DetailLocation.fromJson(Map<String, dynamic>.from(json['schoolLocation'] as Map))
            : (json['school_location'] is Map
                ? DetailLocation.fromJson(Map<String, dynamic>.from(json['school_location'] as Map))
                : null),
      );
}

class DetailLocation {
  final double? lat;
  final double? lng;
  final String? label;

  const DetailLocation({
    this.lat,
    this.lng,
    this.label,
  });

  factory DetailLocation.fromJson(Map<String, dynamic> json) => DetailLocation(
        lat: _parseDouble(json['lat'] ?? json['latitude']),
        lng: _parseDouble(json['lng'] ?? json['longitude']),
        label: json['label']?.toString(),
      );
}

class DetailDriver {
  final int id;
  final String name;
  final String? phone;
  final double rating;
  final String? avatarUrl;
  final DetailVehicle? vehicle;

  const DetailDriver({
    required this.id,
    required this.name,
    this.phone,
    required this.rating,
    this.avatarUrl,
    this.vehicle,
  });

  factory DetailDriver.fromJson(Map<String, dynamic> json) => DetailDriver(
        id: _parseInt(json['id']) ?? 0,
        name: json['name']?.toString() ?? json['driver_name']?.toString() ?? json['full_name']?.toString() ?? '',
        phone: json['phone']?.toString(),
        rating: _parseDouble(json['rating']) ?? 5.0,
        avatarUrl: json['avatar_url']?.toString() ?? json['avatar']?.toString() ?? json['avatarUrl']?.toString(),
        vehicle: json['vehicle'] is Map
            ? DetailVehicle.fromJson(Map<String, dynamic>.from(json['vehicle'] as Map))
            : null,
      );
}

class DetailVehicle {
  final String? model;
  final String? color;
  final String? plateNumber;

  const DetailVehicle({
    this.model,
    this.color,
    this.plateNumber,
  });

  factory DetailVehicle.fromJson(Map<String, dynamic> json) => DetailVehicle(
        model: json['model']?.toString(),
        color: json['color']?.toString(),
        plateNumber: json['plateNumber']?.toString() ?? json['plate_number']?.toString(),
      );

  String get displayName =>
      [color, model].where((e) => e != null && e.isNotEmpty).join(' ');
}

class DetailSchedule {
  final String? shift;
  final String? shiftLabel;
  final String? pickupZoneName;
  final String? schoolName;
  final DetailLocation? homeLocation;
  final String? pickupTime;
  final String? dropoffTime;

  const DetailSchedule({
    this.shift,
    this.shiftLabel,
    this.pickupZoneName,
    this.schoolName,
    this.homeLocation,
    this.pickupTime,
    this.dropoffTime,
  });

  factory DetailSchedule.fromJson(Map<String, dynamic> json) {
    final pTime = json['pickupTime']?.toString() ?? json['pickup_time']?.toString();
    final dTime = json['dropoffTime']?.toString() ?? json['dropoff_time']?.toString();

    String? derivedShiftLabel;
    if (pTime != null && pTime.isNotEmpty && dTime != null && dTime.isNotEmpty) {
      derivedShiftLabel = 'both';
    } else if (pTime != null && pTime.isNotEmpty) {
      derivedShiftLabel = 'morning';
    } else if (dTime != null && dTime.isNotEmpty) {
      derivedShiftLabel = 'evening';
    }

    return DetailSchedule(
      shift: json['shift']?.toString() ?? json['direction']?.toString(),
      shiftLabel: json['shiftLabel']?.toString() ??
          json['shift_label']?.toString() ??
          json['direction_label']?.toString() ??
          json['direction']?.toString() ??
          derivedShiftLabel,
      pickupZoneName: json['pickupZoneName']?.toString() ?? json['pickup_zone_name']?.toString() ?? json['pickup_location']?['label']?.toString(),
      schoolName: json['schoolName']?.toString() ?? json['school_name']?.toString() ?? json['child']?['school_name']?.toString(),
      homeLocation: json['homeLocation'] is Map
          ? DetailLocation.fromJson(Map<String, dynamic>.from(json['homeLocation'] as Map))
          : (json['home_location'] is Map
              ? DetailLocation.fromJson(Map<String, dynamic>.from(json['home_location'] as Map))
              : (json['pickup_location'] is Map
                  ? DetailLocation.fromJson(Map<String, dynamic>.from(json['pickup_location'] as Map))
                  : null)),
      pickupTime: pTime,
      dropoffTime: dTime,
    );
  }
}

class DetailBilling {
  final String? subscriptionType;
  final double totalPrice;
  final double childPrice;
  final String? currency;
  final String? startsAt;
  final String? endsAt;
  final int? remainingDays;
  final bool autoRenew;
  final String? paymentMethod;

  const DetailBilling({
    this.subscriptionType,
    required this.totalPrice,
    required this.childPrice,
    this.currency,
    this.startsAt,
    this.endsAt,
    this.remainingDays,
    required this.autoRenew,
    this.paymentMethod,
  });

  factory DetailBilling.fromJson(Map<String, dynamic> json) => DetailBilling(
        subscriptionType: json['subscriptionType']?.toString() ?? json['subscription_type']?.toString() ?? json['subscription_period']?.toString(),
        totalPrice: _parseDouble(json['totalPrice'] ?? json['total_price'] ?? json['amount'] ?? json['price']) ?? 0.0,
        childPrice: _parseDouble(json['childPrice'] ?? json['child_price'] ?? json['price_per_child']) ?? 0.0,
        currency: json['currency']?.toString() ?? 'دينار',
        startsAt: json['startsAt']?.toString() ?? json['starts_at']?.toString() ?? json['start_date']?.toString() ?? json['startDate']?.toString(),
        endsAt: json['endsAt']?.toString() ?? json['ends_at']?.toString() ?? json['end_date']?.toString() ?? json['endDate']?.toString(),
        remainingDays: _parseInt(json['remainingDays'] ?? json['remaining_days'] ?? json['days_remaining']),
        autoRenew: json['autoRenew'] == true || json['auto_renew'] == true,
        paymentMethod: json['paymentMethod']?.toString() ?? json['payment_method']?.toString(),
      );

  String get formattedTotalPrice {
    return '${totalPrice.toStringAsFixed(2)} دينار';
  }

  String get formattedChildPrice {
    return '${childPrice.toStringAsFixed(2)} دينار';
  }
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
