import 'package:kids_transport/core/utils/subscription_enums.dart';

/// جسم طلب الاشتراك — POST /api/parent/requests
///
/// عقد الباك إند:
/// {
///   "driver_id": 5,
///   "children": [
///     {
///       "child_id": 14,
///       "subscription_type": "multi_day",
///       "trip_direction": "both",
///       "timing": "MORNING",
///       "start_date": "2026-09-10",
///       "end_date": "2026-10-10"
///     }
///   ],
///   "notes": "ملاحظات إضافية"
/// }
class SubscriptionRequest {
  final int driverId;
  final String? notes;
  final List<SubscriptionChildRequest> children;

  SubscriptionRequest({
    required this.driverId,
    this.notes,
    required this.children,
  });

  Map<String, dynamic> toJson() {
    return {
      'driver_id': driverId,
      'children': children.map((c) => c.toJson()).toList(),
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }
}

class SubscriptionChildRequest {
  final int childId;

  /// single_day | multi_day
  final String subscriptionType;

  /// go | return | both
  final String tripDirection;

  /// MORNING | EVENING
  final String timing;

  /// yyyy-MM-dd
  final String startDate;

  /// yyyy-MM-dd — يُرسل فقط في حالة multi_day
  final String? endDate;

  // حقول اختيارية للتوافقية إن لزم في الواجهة
  final int? schoolId;
  final int? pickupAddressId;
  final int? dropoffAddressId;
  final double? pricePerChild;
  final String? childNotes;

  SubscriptionChildRequest({
    required this.childId,
    required String subscriptionType,
    required String tripDirection,
    required String timing,
    required this.startDate,
    String? endDate,
    this.schoolId,
    this.pickupAddressId,
    this.dropoffAddressId,
    this.pricePerChild,
    this.childNotes = '',
  })  : subscriptionType = SubscriptionEnums.normalizeType(subscriptionType),
        tripDirection = SubscriptionEnums.normalizeDirection(tripDirection),
        timing = SubscriptionEnums.normalizeTiming(timing),
        endDate =
            SubscriptionEnums.normalizeType(subscriptionType) == SubscriptionEnums.singleDay
                ? null
                : ((endDate == null || endDate.isEmpty) ? null : endDate);

  Map<String, dynamic> toJson() => {
        'child_id': childId,
        'subscription_type': subscriptionType,
        'trip_direction': tripDirection,
        'timing': timing,
        'start_date': startDate,
        if (subscriptionType == SubscriptionEnums.multiDay &&
            endDate != null &&
            endDate!.isNotEmpty)
          'end_date': endDate,
      };
}

