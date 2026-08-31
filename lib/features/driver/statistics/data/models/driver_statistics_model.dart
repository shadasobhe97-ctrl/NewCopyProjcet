import 'package:kids_transport/core/utils/subscription_enums.dart';

/// النموذج الرئيسي لإحصائيات لوحة تحكم السائق - GET /api/driver/statistics
class DriverStatisticsModel {
  final FinancialStatsModel financialStats;
  final SubscriptionPassengerStatsModel subscriptionAndPassengerStats;
  final TripOperationsStatsModel tripOperationsStats;
  final QuickWidgetsModel? quickWidgets;

  DriverStatisticsModel({
    required this.financialStats,
    required this.subscriptionAndPassengerStats,
    required this.tripOperationsStats,
    this.quickWidgets,
  });

  factory DriverStatisticsModel.fromJson(Map<String, dynamic> json) {
    return DriverStatisticsModel(
      financialStats: FinancialStatsModel.fromJson(
        _toMap(json['financial_stats']),
      ),
      subscriptionAndPassengerStats: SubscriptionPassengerStatsModel.fromJson(
        _toMap(json['subscription_and_passenger_stats']),
      ),
      tripOperationsStats: TripOperationsStatsModel.fromJson(
        _toMap(json['trip_operations_stats']),
      ),
      quickWidgets: json['quick_widgets'] != null
          ? QuickWidgetsModel.fromJson(_toMap(json['quick_widgets']))
          : null,
    );
  }
}

// =========================================================================
// 1. الإحصائيات المالية (Financial Stats)
// =========================================================================
class FinancialStatsModel {
  final NetEarningsModel netEarnings;
  final double expectedActiveEarnings;
  final PendingAndDueModel pendingAndDue;

  FinancialStatsModel({
    required this.netEarnings,
    required this.expectedActiveEarnings,
    required this.pendingAndDue,
  });

  factory FinancialStatsModel.fromJson(Map<String, dynamic> json) {
    return FinancialStatsModel(
      netEarnings: NetEarningsModel.fromJson(_toMap(json['net_earnings'])),
      expectedActiveEarnings: _toDouble(json['expected_active_earnings']) ?? 0.0,
      pendingAndDue: PendingAndDueModel.fromJson(_toMap(json['pending_and_due'])),
    );
  }
}

class NetEarningsModel {
  final double total;
  final double currentMonth;
  final double previousMonth;
  final double growthPercentage;
  final String growthTrend; // "up" | "down" | "same"

  NetEarningsModel({
    required this.total,
    required this.currentMonth,
    required this.previousMonth,
    required this.growthPercentage,
    required this.growthTrend,
  });

  factory NetEarningsModel.fromJson(Map<String, dynamic> json) {
    return NetEarningsModel(
      total: _toDouble(json['total']) ?? 0.0,
      currentMonth: _toDouble(json['current_month']) ?? 0.0,
      previousMonth: _toDouble(json['previous_month']) ?? 0.0,
      growthPercentage: _toDouble(json['growth_percentage']) ?? 0.0,
      growthTrend: json['growth_trend']?.toString() ?? 'same',
    );
  }
}

class PendingAndDueModel {
  final double walletBalance;
  final double escrowPendingBalance;
  final double cashDuesToPlatform;
  final String currency;

  PendingAndDueModel({
    required this.walletBalance,
    required this.escrowPendingBalance,
    required this.cashDuesToPlatform,
    required this.currency,
  });

  factory PendingAndDueModel.fromJson(Map<String, dynamic> json) {
    return PendingAndDueModel(
      walletBalance: _toDouble(json['wallet_balance']) ?? 0.0,
      escrowPendingBalance: _toDouble(json['escrow_pending_balance']) ?? 0.0,
      cashDuesToPlatform: _toDouble(json['cash_dues_to_platform']) ?? 0.0,
      currency: json['currency']?.toString() ?? 'د.ل',
    );
  }
}

// =========================================================================
// 2. إحصائيات الاشتراكات والركاب (Subscription & Passenger Stats)
// =========================================================================
class SubscriptionPassengerStatsModel {
  final int activeStudentsCount;
  final VehicleCapacityModel vehicleCapacity;
  final SubscriptionHistoryModel history;

  SubscriptionPassengerStatsModel({
    required this.activeStudentsCount,
    required this.vehicleCapacity,
    required this.history,
  });

  factory SubscriptionPassengerStatsModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPassengerStatsModel(
      activeStudentsCount: _parseInt(json['active_students_count']) ?? 0,
      vehicleCapacity: VehicleCapacityModel.fromJson(_toMap(json['vehicle_capacity'])),
      history: SubscriptionHistoryModel.fromJson(_toMap(json['history'])),
    );
  }
}

class VehicleCapacityModel {
  final String vehicleModel;
  final String plateNumber;
  final int totalCapacity;
  final int occupiedSeats;
  final int availableSeats;
  final double occupancyRate;

  VehicleCapacityModel({
    required this.vehicleModel,
    required this.plateNumber,
    required this.totalCapacity,
    required this.occupiedSeats,
    required this.availableSeats,
    required this.occupancyRate,
  });

  factory VehicleCapacityModel.fromJson(Map<String, dynamic> json) {
    return VehicleCapacityModel(
      vehicleModel: json['vehicle_model']?.toString() ?? 'غير محدد',
      plateNumber: json['plate_number']?.toString() ?? 'غير محدد',
      totalCapacity: _parseInt(json['total_capacity']) ?? 0,
      occupiedSeats: _parseInt(json['occupied_seats']) ?? 0,
      availableSeats: _parseInt(json['available_seats']) ?? 0,
      occupancyRate: _toDouble(json['occupancy_rate']) ?? 0.0,
    );
  }
}

class SubscriptionHistoryModel {
  final int completedSubscriptionsCount;
  final int cancelledSubscriptionsCount;
  final int totalHistoricalSubscriptions;

  SubscriptionHistoryModel({
    required this.completedSubscriptionsCount,
    required this.cancelledSubscriptionsCount,
    required this.totalHistoricalSubscriptions,
  });

  factory SubscriptionHistoryModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistoryModel(
      completedSubscriptionsCount: _parseInt(json['completed_subscriptions_count']) ?? 0,
      cancelledSubscriptionsCount: _parseInt(json['cancelled_subscriptions_count']) ?? 0,
      totalHistoricalSubscriptions: _parseInt(json['total_historical_subscriptions']) ?? 0,
    );
  }
}

// =========================================================================
// 3. إحصائيات عمليات الرحلات (Trip Operations Stats)
// =========================================================================
class TripOperationsStatsModel {
  final CompletedTripsModel completedTrips;
  final double punctualityRate;
  final AbsencesAndBreakdownsModel absencesAndBreakdowns;

  TripOperationsStatsModel({
    required this.completedTrips,
    required this.punctualityRate,
    required this.absencesAndBreakdowns,
  });

  factory TripOperationsStatsModel.fromJson(Map<String, dynamic> json) {
    return TripOperationsStatsModel(
      completedTrips: CompletedTripsModel.fromJson(_toMap(json['completed_trips'])),
      punctualityRate: _toDouble(json['punctuality_rate']) ?? 100.0,
      absencesAndBreakdowns: AbsencesAndBreakdownsModel.fromJson(
        _toMap(json['absences_and_breakdowns']),
      ),
    );
  }
}

class CompletedTripsModel {
  final int total;
  final int morningTrips;
  final int eveningTrips;
  final int todayCompleted;

  CompletedTripsModel({
    required this.total,
    required this.morningTrips,
    required this.eveningTrips,
    required this.todayCompleted,
  });

  factory CompletedTripsModel.fromJson(Map<String, dynamic> json) {
    return CompletedTripsModel(
      total: _parseInt(json['total']) ?? 0,
      morningTrips: _parseInt(json['morning_trips']) ?? 0,
      eveningTrips: _parseInt(json['evening_trips']) ?? 0,
      todayCompleted: _parseInt(json['today_completed']) ?? 0,
    );
  }
}

class AbsencesAndBreakdownsModel {
  final int absenceDaysCount;
  final int vehicleBreakdownsCount;
  final int totalDowntimeDays;

  AbsencesAndBreakdownsModel({
    required this.absenceDaysCount,
    required this.vehicleBreakdownsCount,
    required this.totalDowntimeDays,
  });

  factory AbsencesAndBreakdownsModel.fromJson(Map<String, dynamic> json) {
    return AbsencesAndBreakdownsModel(
      absenceDaysCount: _parseInt(json['absence_days_count']) ?? 0,
      vehicleBreakdownsCount: _parseInt(json['vehicle_breakdowns_count']) ?? 0,
      totalDowntimeDays: _parseInt(json['total_downtime_days']) ?? 0,
    );
  }
}

// =========================================================================
// 4. الأدوات السريعة (Quick Widgets)
// =========================================================================
class QuickWidgetsModel {
  final ExpiringSoonSubscriptionsModel? expiringSoonSubscriptions;
  final DocumentsStatusModel? documentsStatus;

  QuickWidgetsModel({
    this.expiringSoonSubscriptions,
    this.documentsStatus,
  });

  factory QuickWidgetsModel.fromJson(Map<String, dynamic> json) {
    return QuickWidgetsModel(
      expiringSoonSubscriptions: json['expiring_soon_subscriptions'] != null
          ? ExpiringSoonSubscriptionsModel.fromJson(
              _toMap(json['expiring_soon_subscriptions']),
            )
          : null,
      documentsStatus: json['documents_status'] != null
          ? DocumentsStatusModel.fromJson(_toMap(json['documents_status']))
          : null,
    );
  }
}

class ExpiringSoonSubscriptionsModel {
  final int count;
  final int daysThreshold;
  final List<ExpiringSubscriptionItemModel> items;

  ExpiringSoonSubscriptionsModel({
    required this.count,
    required this.daysThreshold,
    required this.items,
  });

  factory ExpiringSoonSubscriptionsModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final List<ExpiringSubscriptionItemModel> itemList = [];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          itemList.add(ExpiringSubscriptionItemModel.fromJson(_toMap(item)));
        }
      }
    }
    return ExpiringSoonSubscriptionsModel(
      count: _parseInt(json['count']) ?? itemList.length,
      daysThreshold: _parseInt(json['days_threshold']) ?? 5,
      items: itemList,
    );
  }
}

class ExpiringSubscriptionItemModel {
  final int subscriptionId;
  final int childId;
  final String childName;
  final String schoolName;
  final String endDate;
  final int daysRemaining;
  final String direction;

  ExpiringSubscriptionItemModel({
    required this.subscriptionId,
    required this.childId,
    required this.childName,
    required this.schoolName,
    required this.endDate,
    required this.daysRemaining,
    required this.direction,
  });

  String get directionDisplayLabel => SubscriptionEnums.directionLabel(direction);

  factory ExpiringSubscriptionItemModel.fromJson(Map<String, dynamic> json) {
    return ExpiringSubscriptionItemModel(
      subscriptionId: _parseInt(json['subscription_id']) ?? 0,
      childId: _parseInt(json['child_id']) ?? 0,
      childName: json['child_name']?.toString() ?? 'بدون اسم',
      schoolName: json['school_name']?.toString() ?? 'غير محدد',
      endDate: json['end_date']?.toString() ?? '',
      daysRemaining: _parseInt(json['days_remaining']) ?? 0,
      direction: json['direction']?.toString() ?? 'both',
    );
  }
}

class DocumentsStatusModel {
  final String overallIndicator; // "green" | "yellow" | "red"
  final String overallStatusLabel;
  final DocumentItemModel? license;
  final DocumentItemModel? insurance;

  DocumentsStatusModel({
    required this.overallIndicator,
    required this.overallStatusLabel,
    this.license,
    this.insurance,
  });

  factory DocumentsStatusModel.fromJson(Map<String, dynamic> json) {
    return DocumentsStatusModel(
      overallIndicator: json['overall_indicator']?.toString() ?? 'green',
      overallStatusLabel: json['overall_status_label']?.toString() ??
          'كافة الوثائق الرسمية سارية ومفعلة',
      license: json['license'] != null
          ? DocumentItemModel.fromJson(_toMap(json['license']))
          : null,
      insurance: json['insurance'] != null
          ? DocumentItemModel.fromJson(_toMap(json['insurance']))
          : null,
    );
  }
}

class DocumentItemModel {
  final String label;
  final String? licenseNumber;
  final String expiryDate;
  final int daysRemaining;
  final bool isExpired;
  final String indicator; // "green" | "yellow" | "red"
  final String statusLabel;

  DocumentItemModel({
    required this.label,
    this.licenseNumber,
    required this.expiryDate,
    required this.daysRemaining,
    required this.isExpired,
    required this.indicator,
    required this.statusLabel,
  });

  factory DocumentItemModel.fromJson(Map<String, dynamic> json) {
    return DocumentItemModel(
      label: json['label']?.toString() ?? 'وثيقة رسمية',
      licenseNumber: json['license_number']?.toString(),
      expiryDate: json['expiry_date']?.toString() ?? '',
      daysRemaining: _parseInt(json['days_remaining']) ?? 0,
      isExpired: json['is_expired'] == true ||
          json['is_expired']?.toString() == '1' ||
          json['is_expired']?.toString().toLowerCase() == 'true',
      indicator: json['indicator']?.toString() ?? 'green',
      statusLabel: json['status_label']?.toString() ?? 'سارية ومفعلة',
    );
  }
}

// =========================================================================
// التوابع المساعدة للتحليل الآمن
// =========================================================================
Map<String, dynamic> _toMap(dynamic raw) {
  if (raw is Map) {
    return Map<String, dynamic>.from(raw);
  }
  return <String, dynamic>{};
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}
