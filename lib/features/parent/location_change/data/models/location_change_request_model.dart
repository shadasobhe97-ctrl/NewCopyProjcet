import 'location_change_options_model.dart';
import 'location_change_preview_model.dart';

class LocationChangeRequestModel {
  final int id;
  final int activeSubscriptionId;
  final String pointType;
  final String changeDate;
  final bool isSingleDay;
  final double distanceKm;
  final String feeTier;
  final String feeTierLabel;
  final double feeAmount;
  final String currency;
  final FeeBreakdownModel feeBreakdown;
  final bool isSettled;
  final String status;
  final String? rejectionReason;
  final LocationPointModel? newLocation;
  final String? childName;
  final String? driverName;
  final String? parentName;
  final String? respondedAt;
  final String? createdAt;

  LocationChangeRequestModel({
    required this.id,
    required this.activeSubscriptionId,
    required this.pointType,
    required this.changeDate,
    required this.isSingleDay,
    required this.distanceKm,
    required this.feeTier,
    required this.feeTierLabel,
    required this.feeAmount,
    required this.currency,
    required this.feeBreakdown,
    required this.isSettled,
    required this.status,
    this.rejectionReason,
    this.newLocation,
    this.childName,
    this.driverName,
    this.parentName,
    this.respondedAt,
    this.createdAt,
  });

  factory LocationChangeRequestModel.fromJson(Map<String, dynamic> json) {
    final childObj = json['child'] is Map ? json['child'] as Map<String, dynamic> : {};
    final driverObj = json['driver'] is Map ? json['driver'] as Map<String, dynamic> : {};
    final parentObj = json['parent'] is Map ? json['parent'] as Map<String, dynamic> : {};

    final breakdownObj = json['fee_breakdown'] is Map
        ? Map<String, dynamic>.from(json['fee_breakdown'])
        : <String, dynamic>{};

    return LocationChangeRequestModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      activeSubscriptionId: int.tryParse(json['active_subscription_id']?.toString() ?? '') ?? 0,
      pointType: json['point_type']?.toString() ?? 'pickup',
      changeDate: json['change_date']?.toString() ?? '',
      isSingleDay: json['is_single_day'] == true,
      distanceKm: double.tryParse(json['distance_km']?.toString() ?? '') ?? 0.0,
      feeTier: json['fee_tier']?.toString() ?? '',
      feeTierLabel: json['fee_tier_label']?.toString() ?? '',
      feeAmount: double.tryParse(json['fee_amount']?.toString() ?? '') ?? 0.0,
      currency: json['currency']?.toString() ?? 'د.ل',
      feeBreakdown: FeeBreakdownModel.fromJson(breakdownObj),
      isSettled: json['is_settled'] == true,
      status: json['status']?.toString() ?? 'pending',
      rejectionReason: json['rejection_reason']?.toString(),
      newLocation: json['new_location'] is Map
          ? LocationPointModel.fromJson(Map<String, dynamic>.from(json['new_location']))
          : null,
      childName: childObj['name']?.toString(),
      driverName: driverObj['name']?.toString(),
      parentName: parentObj['name']?.toString(),
      respondedAt: json['responded_at']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
