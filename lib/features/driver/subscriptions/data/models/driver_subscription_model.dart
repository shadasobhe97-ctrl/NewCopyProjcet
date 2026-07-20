// نموذج الاشتراكات النشطة للسائق - GET /api/driver/active-subscriptions
// الفلاتر: current_active | pending_start | completed | cancelled

class DriverSubscriptionModel {
  final int id;
  final String status; // active | pending_start | completed | cancelled
  final String? pickupTime;
  final String? dropoffTime;
  final double? pickupLat;
  final double? pickupLng;
  final String? pickupLabel;
  final double? dropoffLat;
  final double? dropoffLng;
  final String? dropoffLabel;
  final DriverSubChild child;
  final DriverSubParent parent;
  final DriverSubContract? contract;
  final String createdAt;

  const DriverSubscriptionModel({
    required this.id,
    required this.status,
    this.pickupTime,
    this.dropoffTime,
    this.pickupLat,
    this.pickupLng,
    this.pickupLabel,
    this.dropoffLat,
    this.dropoffLng,
    this.dropoffLabel,
    required this.child,
    required this.parent,
    this.contract,
    required this.createdAt,
  });

  // ── الحالة بالعربية ──
  String get statusDisplayLabel {
    switch (status.toLowerCase()) {
      case 'active':
        return 'نشط';
      case 'pending_start':
        return 'ينتظر البدء';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  static int? _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '');
  }

  factory DriverSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return DriverSubscriptionModel(
      id: _parseInt(json['id']) ?? 0,
      status: json['status']?.toString() ?? 'active',
      pickupTime: json['pickup_time']?.toString(),
      dropoffTime: json['dropoff_time']?.toString(),
      pickupLat: (json['pickup_lat'] as num?)?.toDouble(),
      pickupLng: (json['pickup_lng'] as num?)?.toDouble(),
      pickupLabel: json['pickup_label']?.toString(),
      dropoffLat: (json['dropoff_lat'] as num?)?.toDouble(),
      dropoffLng: (json['dropoff_lng'] as num?)?.toDouble(),
      dropoffLabel: json['dropoff_label']?.toString(),
      child: json['child'] is Map
          ? DriverSubChild.fromJson(
              Map<String, dynamic>.from(json['child'] as Map))
          : DriverSubChild.empty(),
      parent: json['parent'] is Map
          ? DriverSubParent.fromJson(
              Map<String, dynamic>.from(json['parent'] as Map))
          : DriverSubParent.empty(),
      contract: json['contract'] is Map
          ? DriverSubContract.fromJson(
              Map<String, dynamic>.from(json['contract'] as Map))
          : null,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

// ── الطفل ──
class DriverSubChild {
  final int id;
  final String? name;
  final String schoolName;

  const DriverSubChild({
    required this.id,
    this.name,
    required this.schoolName,
  });

  String get displayName => name ?? 'غير محدد';

  factory DriverSubChild.fromJson(Map<String, dynamic> json) {
    return DriverSubChild(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString(),
      schoolName: json['school_name']?.toString() ?? '',
    );
  }

  factory DriverSubChild.empty() => const DriverSubChild(id: 0, schoolName: '');
}

// ── ولي الأمر ──
class DriverSubParent {
  final int id;
  final String name;
  final String? phone;
  final String? avatarUrl;

  const DriverSubParent({
    required this.id,
    required this.name,
    this.phone,
    this.avatarUrl,
  });

  factory DriverSubParent.fromJson(Map<String, dynamic> json) {
    return DriverSubParent(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
    );
  }

  factory DriverSubParent.empty() =>
      const DriverSubParent(id: 0, name: '');
}

// ── العقد ──
class DriverSubContract {
  final int id;
  final String contractNumber;
  final String startDate;
  final String endDate;
  final double totalPrice;
  final String status;

  const DriverSubContract({
    required this.id,
    required this.contractNumber,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
  });

  factory DriverSubContract.fromJson(Map<String, dynamic> json) {
    return DriverSubContract(
      id: json['id'] as int? ?? 0,
      contractNumber: json['contract_number']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? '',
    );
  }
}
