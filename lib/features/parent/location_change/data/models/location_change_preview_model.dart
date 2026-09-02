import 'location_change_options_model.dart';

class FeeBreakdownModel {
  final double grossFee;
  final double commissionRate;
  final double platformCommission;
  final double driverNetFee;
  final String currency;

  FeeBreakdownModel({
    required this.grossFee,
    required this.commissionRate,
    required this.platformCommission,
    required this.driverNetFee,
    required this.currency,
  });

  factory FeeBreakdownModel.fromJson(Map<String, dynamic> json) {
    return FeeBreakdownModel(
      grossFee: double.tryParse(json['gross_fee']?.toString() ?? '') ?? 0.0,
      commissionRate: double.tryParse(json['commission_rate']?.toString() ?? '') ?? 0.0,
      platformCommission: double.tryParse(json['platform_commission']?.toString() ?? '') ?? 0.0,
      driverNetFee: double.tryParse(json['driver_net_fee']?.toString() ?? '') ?? 0.0,
      currency: json['currency']?.toString() ?? 'د.ل',
    );
  }
}

class FeeTierItemModel {
  final String tier;
  final String label;
  final double fee;

  FeeTierItemModel({
    required this.tier,
    required this.label,
    required this.fee,
  });

  factory FeeTierItemModel.fromJson(Map<String, dynamic> json) {
    return FeeTierItemModel(
      tier: json['tier']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      fee: double.tryParse(json['fee']?.toString() ?? '') ?? 0.0,
    );
  }
}

class LocationChangePreviewModel {
  final int activeSubscriptionId;
  final String pointType;
  final String changeDate;
  final LocationPointModel? currentLocation;
  final LocationPointModel? newLocation;
  final double distanceKm;
  final String feeTier;
  final String feeTierLabel;
  final FeeBreakdownModel feeBreakdown;
  final List<FeeTierItemModel> feeTiers;
  final String currency;
  final String? childName;
  final String? driverName;

  LocationChangePreviewModel({
    required this.activeSubscriptionId,
    required this.pointType,
    required this.changeDate,
    this.currentLocation,
    this.newLocation,
    required this.distanceKm,
    required this.feeTier,
    required this.feeTierLabel,
    required this.feeBreakdown,
    required this.feeTiers,
    required this.currency,
    this.childName,
    this.driverName,
  });

  factory LocationChangePreviewModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;

    final tripObj = data['trip'] is Map ? data['trip'] as Map<String, dynamic> : {};
    final childObj = tripObj['child'] is Map ? tripObj['child'] as Map<String, dynamic> : {};
    final driverObj = tripObj['driver'] is Map ? tripObj['driver'] as Map<String, dynamic> : {};

    final breakdownObj = data['fee_breakdown'] is Map
        ? Map<String, dynamic>.from(data['fee_breakdown'])
        : <String, dynamic>{};

    final tiersList = (data['fee_tiers'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => FeeTierItemModel.fromJson(e))
        .toList();

    return LocationChangePreviewModel(
      activeSubscriptionId: int.tryParse(data['active_subscription_id']?.toString() ?? '') ?? 0,
      pointType: data['point_type']?.toString() ?? 'pickup',
      changeDate: data['change_date']?.toString() ?? '',
      currentLocation: data['current_location'] is Map
          ? LocationPointModel.fromJson(Map<String, dynamic>.from(data['current_location']))
          : null,
      newLocation: data['new_location'] is Map
          ? LocationPointModel.fromJson(Map<String, dynamic>.from(data['new_location']))
          : null,
      distanceKm: double.tryParse(data['distance_km']?.toString() ?? '') ?? 0.0,
      feeTier: data['fee_tier']?.toString() ?? '',
      feeTierLabel: data['fee_tier_label']?.toString() ?? '',
      feeBreakdown: FeeBreakdownModel.fromJson(breakdownObj),
      feeTiers: tiersList,
      currency: data['currency']?.toString() ?? 'د.ل',
      childName: childObj['name']?.toString(),
      driverName: driverObj['name']?.toString(),
    );
  }
}
