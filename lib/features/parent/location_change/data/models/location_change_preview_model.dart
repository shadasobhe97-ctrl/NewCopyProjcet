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

class GroupedRequestModel {
  final int driverId;
  final String driverName;
  final List<ChildOptionModel> children;
  final double extraDistanceKm;
  final double feeAmount;
  final String? feeTierLabel;
  final double? driverNetFee;

  GroupedRequestModel({
    required this.driverId,
    required this.driverName,
    required this.children,
    required this.extraDistanceKm,
    required this.feeAmount,
    this.feeTierLabel,
    this.driverNetFee,
  });

  factory GroupedRequestModel.fromJson(Map<String, dynamic> json) {
    final childrenList = (json['children'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => ChildOptionModel.fromJson(e))
        .toList();

    final dist = double.tryParse(json['distance_km']?.toString() ?? json['extra_distance_km']?.toString() ?? '') ?? 0.0;
    final fee = double.tryParse(json['fee_amount']?.toString() ?? json['fee']?.toString() ?? '') ?? 0.0;
    final tier = json['fee_tier_label']?.toString() ?? json['tier_label']?.toString();
    final net = double.tryParse(json['driver_net_fee']?.toString() ?? '');

    return GroupedRequestModel(
      driverId: int.tryParse(json['driver_id']?.toString() ?? '') ?? 0,
      driverName: json['driver_name']?.toString() ?? json['driver']?['name']?.toString() ?? 'سائق',
      children: childrenList,
      extraDistanceKm: dist,
      feeAmount: fee,
      feeTierLabel: tier,
      driverNetFee: net,
    );
  }
}

class LocationChangePreviewModel {
  final String date;
  final String pointType;
  final LocationPointModel? newLocation;
  final List<GroupedRequestModel> groupedRequests;
  final double totalFee;
  final double? walletBalance;
  final double? walletAfter;
  final String currency;

  LocationChangePreviewModel({
    required this.date,
    required this.pointType,
    this.newLocation,
    required this.groupedRequests,
    required this.totalFee,
    this.walletBalance,
    this.walletAfter,
    required this.currency,
  });

  factory LocationChangePreviewModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;

    final newLocObj = data['new_location'] is Map
        ? LocationPointModel.fromJson(Map<String, dynamic>.from(data['new_location']))
        : null;

    final groupedList = (data['grouped_requests'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => GroupedRequestModel.fromJson(e))
        .toList();

    final summaryObj = data['summary'] is Map ? data['summary'] as Map<String, dynamic> : {};
    final totalFeeVal = double.tryParse(summaryObj['total_fee']?.toString() ?? data['total_fee']?.toString() ?? '') ??
        groupedList.fold<double>(0.0, (sum, g) => sum + g.feeAmount);

    final walletBalanceVal = double.tryParse(summaryObj['wallet_balance']?.toString() ?? data['wallet_balance']?.toString() ?? '');
    final walletAfterVal = double.tryParse(summaryObj['wallet_after']?.toString() ?? data['wallet_after']?.toString() ?? '');

    final currencyVal = summaryObj['currency']?.toString() ?? data['currency']?.toString() ?? 'د.ل';

    return LocationChangePreviewModel(
      date: data['date']?.toString() ?? '',
      pointType: data['point_type']?.toString() ?? 'pickup',
      newLocation: newLocObj,
      groupedRequests: groupedList,
      totalFee: totalFeeVal,
      walletBalance: walletBalanceVal,
      walletAfter: walletAfterVal,
      currency: currencyVal,
    );
  }
}
