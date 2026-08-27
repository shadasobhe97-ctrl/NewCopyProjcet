import 'package:kids_transport/core/utils/subscription_enums.dart';

/// جسم طلب الاشتراك — POST /api/parent/subscription-requests
///
/// عقد الباك إند:
/// {
///   "driver_id": 189,
///   "notes": "...",
///   "children": [ { child_id, school_id, subscription_type, trip_direction,
///                   timing, start_date, end_date, pickup_address_id,
///                   dropoff_address_id, price_per_child } ]
/// }
///
/// ملاحظة مهمة: كل طفل يحمل إعداداته الخاصة (النوع/الاتجاه/الفترة/التواريخ)
/// ولا تُفرض عليه إعدادات الطفل الأول.
class SubscriptionRequest {
  final int driverId;
  final String notes;
  final List<SubscriptionChildRequest> children;

  SubscriptionRequest({
    required this.driverId,
    this.notes = '',
    required this.children,
  });

  Map<String, dynamic> toJson() {
    return {
      'driver_id': driverId,
      if (notes.isNotEmpty) 'notes': notes,
      'children': children.map((c) => c.toJson()).toList(),
    };
  }
}

class SubscriptionChildRequest {
  final int childId;
  final int schoolId;

  /// single_day | multi_day
  final String subscriptionType;

  /// go | return | both
  final String tripDirection;

  /// MORNING | EVENING | BOTH
  final String timing;

  /// yyyy-MM-dd
  final String startDate;

  /// yyyy-MM-dd — يساوي startDate في حالة single_day
  final String? endDate;

  final int pickupAddressId;
  final int dropoffAddressId;
  final double pricePerChild;
  final String childNotes;

  SubscriptionChildRequest({
    required this.childId,
    required this.schoolId,
    required String subscriptionType,
    required String tripDirection,
    required String timing,
    required this.startDate,
    String? endDate,
    required this.pickupAddressId,
    required this.dropoffAddressId,
    required this.pricePerChild,
    this.childNotes = '',
  })  : subscriptionType = SubscriptionEnums.normalizeType(subscriptionType),
        tripDirection = SubscriptionEnums.normalizeDirection(tripDirection),
        timing = SubscriptionEnums.normalizeTiming(timing),
        endDate =
            SubscriptionEnums.normalizeType(subscriptionType) == SubscriptionEnums.singleDay
                ? startDate
                : ((endDate == null || endDate.isEmpty) ? null : endDate);

  Map<String, dynamic> toJson() => {
        'child_id': childId,
        'school_id': schoolId,
        'subscription_type': subscriptionType,
        'trip_direction': tripDirection,
        'timing': timing,
        'start_date': startDate,
        if (endDate != null && endDate!.isNotEmpty) 'end_date': endDate,
        'pickup_address_id': pickupAddressId,
        'dropoff_address_id': dropoffAddressId,
        'price_per_child': pricePerChild,
        if (childNotes.isNotEmpty) 'child_notes': childNotes,
      };
}
