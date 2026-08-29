// نموذج الاشتراك النشط - GET /api/parent/active-subscriptions
// نفس شكل رد GET /api/parent/active-subscriptions/{id}

class ActiveSubscriptionModel {
  final int id;
  final int requestId;
  final String status; // accepted | pending_start | completed | cancelled
  final String? statusLabel;
  final double totalPrice;
  final ActiveChild child;
  final ActiveDriver driver;
  final String createdAt;

  const ActiveSubscriptionModel({
    required this.id,
    required this.requestId,
    required this.status,
    this.statusLabel,
    required this.totalPrice,
    required this.child,
    required this.driver,
    required this.createdAt,
  });

  String get statusDisplayLabel {
    if (statusLabel != null && statusLabel!.isNotEmpty) {
      return statusLabel!;
    }
    switch (status.toLowerCase()) {
      case 'active':
      case 'accepted':
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
    final tp = totalPrice;
    if (tp == tp.toInt()) {
      return '${tp.toInt()} دينار';
    }
    return '${tp.toStringAsFixed(2)} دينار';
  }

  String get childName => child.name ?? child.schoolName;

  factory ActiveSubscriptionModel.fromJson(Map<String, dynamic> json) {
    final childJson = json['child'] as Map<String, dynamic>? ?? {};

    return ActiveSubscriptionModel(
      id: _parseInt(json['active_subscription_id'] ?? json['id'] ?? json['subscription_id']) ?? 0,
      requestId: _parseInt(json['subscription_request_id'] ?? json['request_id'] ?? json['id']) ?? 0,
      status: json['status']?.toString() ?? 'accepted',
      statusLabel: json['statusLabel']?.toString() ?? json['status_label']?.toString(),
      totalPrice: _parseDouble(json['total_price']) ?? 0.0,
      child: ActiveChild.fromJson(childJson),
      driver: ActiveDriver.fromJson(
        json['driver'] as Map<String, dynamic>? ?? {},
      ),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subscription_request_id': requestId,
        'status': status,
        if (statusLabel != null) 'statusLabel': statusLabel,
        'total_price': totalPrice,
        'child': child.toJson(),
        'driver': driver.toJson(),
        'created_at': createdAt,
      };
}

// ── الطفل (طفل واحد لكل اشتراك) ──
class ActiveChild {
  final int id;
  final String? name;
  final String schoolName;
  final String? schoolAddress;
  final String? startDate;
  final String? endDate;

  const ActiveChild({
    required this.id,
    this.name,
    required this.schoolName,
    this.schoolAddress,
    this.startDate,
    this.endDate,
  });

  factory ActiveChild.fromJson(Map<String, dynamic> json) {
    final school = json['School'] as Map<String, dynamic>? ??
        json['school'] as Map<String, dynamic>?;
    final details = json['details'] as Map<String, dynamic>? ?? {};

    return ActiveChild(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString(),
      schoolName: school?['name']?.toString() ?? '',
      schoolAddress: school?['address']?.toString(),
      startDate: details['start_date']?.toString(),
      endDate: details['end_date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (name != null) 'name': name,
        'school_name': schoolName,
      };
}

// ── السائق ──
class ActiveDriver {
  final int id;
  final String name;
  final String? phone;
  final String? avatarUrl;

  const ActiveDriver({
    required this.id,
    required this.name,
    this.phone,
    this.avatarUrl,
  });

  factory ActiveDriver.fromJson(Map<String, dynamic> json) => ActiveDriver(
        id: _parseInt(json['id']) ?? 0,
        name: json['name']?.toString() ?? '',
        phone: json['phone']?.toString(),
        avatarUrl: json['photo']?.toString() ?? json['avatar_url']?.toString() ?? json['avatar']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (phone != null) 'phone': phone,
        if (avatarUrl != null) 'photo': avatarUrl,
      };
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
