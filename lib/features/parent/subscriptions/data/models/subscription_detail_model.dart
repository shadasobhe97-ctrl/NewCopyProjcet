import 'package:kids_transport/core/utils/subscription_enums.dart';
import 'subscription_location_model.dart';

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

  factory SubscriptionDetailModel.fromJson(Map<String, dynamic> json) {
    final childJson = json['child'] as Map<String, dynamic>? ?? {};
    final detailsJson = childJson['details'] as Map<String, dynamic>? ?? {};

    return SubscriptionDetailModel(
      id: _parseInt(json['active_subscription_id'] ?? json['id'] ?? json['subscription_id']) ?? 0,
      status: json['status']?.toString() ?? '',
      statusLabel: json['statusLabel']?.toString() ?? json['status_label']?.toString() ?? '',
      child: DetailChild.fromJson(childJson),
      driver: DetailDriver.fromJson(json['driver'] as Map<String, dynamic>? ?? {}),
      schedule: DetailSchedule.fromJson(childJson, detailsJson),
      billing: DetailBilling.fromJson(
        detailsJson,
        rootTotalPrice: _parseDouble(json['total_price']),
      ),
      requestId: _parseInt(json['subscription_request_id'] ??
              json['requestId'] ??
              json['request_id'] ??
              json['id']) ??
          0,
      cancelReason: json['cancelReason']?.toString() ?? json['cancel_reason']?.toString(),
      cancelledAt: json['cancelledAt']?.toString() ?? json['cancelled_at']?.toString(),
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '',
    );
  }
}

class DetailChild {
  final int id;
  final String? name;
  final String? avatar;
  final String? avatarInitials;
  final String schoolName;
  final String? schoolAddress;
  final DetailLocation? schoolLocation;

  const DetailChild({
    required this.id,
    this.name,
    this.avatar,
    this.avatarInitials,
    required this.schoolName,
    this.schoolAddress,
    this.schoolLocation,
  });

  factory DetailChild.fromJson(Map<String, dynamic> json) {
    final school = json['School'] as Map<String, dynamic>? ??
        json['school'] as Map<String, dynamic>?;

    return DetailChild(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? json['child_name']?.toString() ?? json['childName']?.toString(),
      avatar: json['photo']?.toString() ??
          json['avatar']?.toString() ??
          json['photo_url']?.toString() ??
          json['image']?.toString(),
      avatarInitials: json['avatarInitials']?.toString() ?? json['avatar_initials']?.toString(),
      schoolName: school?['name']?.toString() ??
          json['schoolName']?.toString() ??
          json['school_name']?.toString() ??
          '',
      schoolAddress: school?['address']?.toString(),
      schoolLocation: school != null
          ? DetailLocation.fromJson(Map<String, dynamic>.from(school))
          : (json['schoolLocation'] is Map
              ? DetailLocation.fromJson(Map<String, dynamic>.from(json['schoolLocation'] as Map))
              : (json['school_location'] is Map
                  ? DetailLocation.fromJson(Map<String, dynamic>.from(json['school_location'] as Map))
                  : null)),
    );
  }
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
        label: json['label']?.toString() ?? json['name']?.toString(),
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
        avatarUrl: json['photo']?.toString() ??
            json['avatar_url']?.toString() ??
            json['avatar']?.toString() ??
            json['avatarUrl']?.toString(),
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
  final String? timing;
  final String? pickupZoneName;
  final String? schoolName;
  final SubscriptionLocationModel? homeLocation;

  const DetailSchedule({
    this.shift,
    this.shiftLabel,
    this.timing,
    this.pickupZoneName,
    this.schoolName,
    this.homeLocation,
  });

  /// [childJson] هو كائن الطفل الكامل (فيه Home/School)، و[detailsJson]
  /// هو child['details'] (فيه trip_direction/timing وغيرها)
  factory DetailSchedule.fromJson(
    Map<String, dynamic> childJson,
    Map<String, dynamic> detailsJson,
  ) {
    final home = childJson['Home'] as Map<String, dynamic>? ??
        childJson['home'] as Map<String, dynamic>?;
    final school = childJson['School'] as Map<String, dynamic>? ??
        childJson['school'] as Map<String, dynamic>?;
    final direction = detailsJson['trip_direction']?.toString();

    return DetailSchedule(
      shift: direction,
      shiftLabel: direction,
      timing: detailsJson['timing']?.toString(),
      pickupZoneName: home?['name']?.toString(),
      schoolName: school?['name']?.toString(),
      // العنوان الخام للمنزل مقصود إخفاؤه، الاسم بس هو المعروض
      homeLocation: home != null
          ? SubscriptionLocationModel(
              name: home['name']?.toString(),
              latitude: _parseDouble(home['latitude']),
              longitude: _parseDouble(home['longitude']),
            )
          : null,
    );
  }
}

class DetailBilling {
  final String? subscriptionType;
  final double totalPrice;
  final double childPrice;
  final double? tripPrice;
  final int? workingDaysCount;
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
    this.tripPrice,
    this.workingDaysCount,
    this.currency,
    this.startsAt,
    this.endsAt,
    this.remainingDays,
    required this.autoRenew,
    this.paymentMethod,
  });

  /// [detailsJson] هو child['details']، و[rootTotalPrice] هو السعر
  /// الإجمالي من جذر الرد (total_price)
  factory DetailBilling.fromJson(
    Map<String, dynamic> detailsJson, {
    double? rootTotalPrice,
  }) =>
      DetailBilling(
        subscriptionType: detailsJson['subscription_type_label']?.toString() ??
            detailsJson['subscriptionType']?.toString() ??
            detailsJson['subscription_type']?.toString(),
        totalPrice: rootTotalPrice ?? _parseDouble(detailsJson['total_price']) ?? 0.0,
        childPrice: _parseDouble(detailsJson['price_per_child']) ?? 0.0,
        tripPrice: _parseDouble(detailsJson['trip_price']),
        workingDaysCount: _parseInt(detailsJson['working_days_count']),
        currency: detailsJson['currency']?.toString() ?? 'دينار',
        startsAt: detailsJson['startsAt']?.toString() ??
            detailsJson['starts_at']?.toString() ??
            detailsJson['start_date']?.toString() ??
            detailsJson['startDate']?.toString(),
        endsAt: detailsJson['endsAt']?.toString() ??
            detailsJson['ends_at']?.toString() ??
            detailsJson['end_date']?.toString() ??
            detailsJson['endDate']?.toString(),
        remainingDays: _parseInt(detailsJson['remainingDays'] ??
            detailsJson['remaining_days'] ??
            detailsJson['days_remaining']),
        autoRenew: detailsJson['autoRenew'] == true || detailsJson['auto_renew'] == true,
        paymentMethod: detailsJson['paymentMethod']?.toString() ?? detailsJson['payment_method']?.toString(),
      );

  String get subscriptionTypeDisplayLabel =>
      SubscriptionEnums.typeLabel(subscriptionType);

  String get formattedTotalPrice {
    return '${totalPrice.toStringAsFixed(2)} دينار';
  }

  String get formattedChildPrice {
    return '${childPrice.toStringAsFixed(2)} دينار';
  }

  String get formattedTripPrice {
    return tripPrice != null ? '${tripPrice!.toStringAsFixed(2)} دينار' : 'غير متوفر';
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
