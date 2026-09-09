import 'package:kids_transport/core/utils/subscription_enums.dart';
import 'package:kids_transport/features/driver/shared/data/models/driver_common_subscription_models.dart';

export 'package:kids_transport/features/driver/shared/data/models/driver_common_subscription_models.dart';

// =============================================================================
// نموذج الاشتراك الموحد للسائق - DriverSubscriptionModel
// يمثل اشتراكاً موحداً على مستوى الطلب ككل يحتوي جميع الأطفال المشمولين
// =============================================================================

class DriverSubscriptionModel {
  final int id;
  final String status;
  final String? statusLabel;
  final DriverParentModel parent;
  final SubscriptionInfoModel subscription;
  final DriverHomeAddressModel? homeAddress;
  final int childrenCount;
  final DriverSubscriptionPricingModel? pricing;
  final List<DriverChildModel> children;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;
  final String? rejectionReason;

  const DriverSubscriptionModel({
    required this.id,
    required this.status,
    this.statusLabel,
    required this.parent,
    required this.subscription,
    this.homeAddress,
    required this.childrenCount,
    this.pricing,
    required this.children,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.rejectionReason,
  });

  /// ترجمة حالة الاشتراك المعتمدة بالعربية
  String get statusDisplayLabel =>
      SubscriptionEnums.statusLabel(status, fallbackLabel: statusLabel);

  /// نوع الاشتراك بالعربية (يوم واحد / عدة أيام فقط)
  String get typeDisplayLabel => subscription.typeDisplayLabel;

  /// اتجاه الرحلة بالعربية
  String get directionDisplayLabel => subscription.directionDisplayLabel;

  /// اسم عنوان الانطلاق / المنزل
  String get pickupLabel => homeAddress?.displayName ?? 'المنزل';

  /// فترة الرحلة
  String get timingDisplayLabel {
    if (children.isNotEmpty && children.first.timing != null) {
      return children.first.timingDisplay;
    }
    return 'غير محدد';
  }

  factory DriverSubscriptionModel.fromJson(Map<String, dynamic> json) {
    final parentJson = json['parent'] is Map
        ? Map<String, dynamic>.from(json['parent'] as Map)
        : <String, dynamic>{};

    final subJson = json['subscription'] is Map
        ? Map<String, dynamic>.from(json['subscription'] as Map)
        : <String, dynamic>{
            'type': json['subscription_type'] ?? json['type'],
            'type_label': json['subscription_type_label'] ?? json['type_label'],
            'direction': json['trip_direction'] ?? json['direction'],
            'direction_label': json['trip_direction_label'] ?? json['direction_label'],
            'start_date': json['start_date'],
            'end_date': json['end_date'],
            'working_days_count': json['working_days_count'],
          };

    final homeJson = json['home_address'] is Map
        ? Map<String, dynamic>.from(json['home_address'] as Map)
        : (json['home'] is Map
            ? Map<String, dynamic>.from(json['home'] as Map)
            : (json['pickup_location'] is Map
                ? Map<String, dynamic>.from(json['pickup_location'] as Map)
                : null));

    final pricingJson = json['pricing'] is Map
        ? Map<String, dynamic>.from(json['pricing'] as Map)
        : null;

    final rawChildren = json['children'];
    final List<DriverChildModel> childrenList = [];
    if (rawChildren is List) {
      for (final c in rawChildren) {
        if (c is Map) {
          childrenList.add(
              DriverChildModel.fromJson(Map<String, dynamic>.from(c)));
        }
      }
    }

    String readStatus = 'active';
    String? readStatusLabel = json['status_label']?.toString();
    if (json['status'] is Map) {
      readStatus = (json['status'] as Map)['value']?.toString() ?? 'active';
      readStatusLabel ??= (json['status'] as Map)['label']?.toString();
    } else if (json['status'] != null) {
      readStatus = json['status'].toString();
    }

    final count = _parseInt(json['children_count']) ?? childrenList.length;

    return DriverSubscriptionModel(
      id: _parseInt(json['id'] ?? json['active_subscription_id'] ?? json['subscription_id']) ?? 0,
      status: readStatus,
      statusLabel: readStatusLabel,
      parent: DriverParentModel.fromJson(parentJson),
      subscription: SubscriptionInfoModel.fromJson(subJson),
      homeAddress: homeJson != null
          ? DriverHomeAddressModel.fromJson(homeJson)
          : null,
      childrenCount: count,
      pricing: pricingJson != null
          ? DriverSubscriptionPricingModel.fromJson(pricingJson)
          : null,
      children: childrenList,
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'status_label': statusLabel,
        'parent': parent.toJson(),
        'subscription': subscription.toJson(),
        'home_address': homeAddress?.toJson(),
        'children_count': childrenCount,
        'pricing': pricing?.toJson(),
        'children': children.map((c) => c.toJson()).toList(),
        'notes': notes,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'rejection_reason': rejectionReason,
      };
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}
