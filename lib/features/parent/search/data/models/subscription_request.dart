import 'package:kids_transport/core/utils/subscription_enums.dart';

/// جسم طلب الاشتراك — POST /api/parent/requests
///
/// عقد الباك إند الجديد:
/// {
///   "driver_id": 1,
///   "subscription_type": "multi_day",
///   "trip_direction": "both",
///   "start_date": "2026-09-10",
///   "end_date": "2026-09-30",
///   "home_address_id": 5,
///   "children": [
///     { "child_id": 1 },
///     { "child_id": 2 }
///   ],
///   "notes": "ملاحظات إضافية"
/// }
class SubscriptionRequest {
  final int driverId;
  final String subscriptionType;
  final String tripDirection;
  final String startDate;
  final String? endDate;
  final int? homeAddressId;
  final Map<String, dynamic>? homeAddress;
  final List<SubscriptionChildRequest> children;
  final String? notes;

  SubscriptionRequest({
    required this.driverId,
    required String subscriptionType,
    required String tripDirection,
    required this.startDate,
    this.endDate,
    this.homeAddressId,
    this.homeAddress,
    required this.children,
    this.notes,
  })  : subscriptionType = SubscriptionEnums.normalizeType(subscriptionType),
        tripDirection = SubscriptionEnums.normalizeDirection(tripDirection);

  Map<String, dynamic> toJson() {
    return {
      'driver_id': driverId,
      'subscription_type': subscriptionType,
      'trip_direction': tripDirection,
      'start_date': startDate,
      if (subscriptionType == SubscriptionEnums.multiDay &&
          endDate != null &&
          endDate!.isNotEmpty)
        'end_date': endDate
      else if (subscriptionType == SubscriptionEnums.singleDay)
        'end_date': startDate,
      if (homeAddressId != null && homeAddressId! > 0)
        'home_address_id': homeAddressId
      else if (homeAddress != null && homeAddress!.isNotEmpty)
        'home_address': homeAddress,
      'children': children.map((c) => c.toJson()).toList(),
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }
}

class SubscriptionChildRequest {
  final int childId;

  SubscriptionChildRequest({
    required this.childId,
  });

  Map<String, dynamic> toJson() => {
        'child_id': childId,
      };
}


