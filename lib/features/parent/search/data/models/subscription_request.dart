class SubscriptionRequest {
  final int driverId;
  final int schoolId;
  final String subscriptionType;
  final String direction;
  final String timing;
  final String startDate;
  final String? endDate;
  final int daysCount;
  final String notes;
  final List<SubscriptionChildRequest> children;

  SubscriptionRequest({
    required this.driverId,
    required this.schoolId,
    required this.subscriptionType,
    required this.direction,
    required this.timing,
    required this.startDate,
    this.endDate,
    required this.daysCount,
    required this.notes,
    required this.children,
  });

  Map<String, dynamic> toJson() {
    return {
      'driver_id': driverId,
      'school_id': schoolId,
      'subscription_type': subscriptionType,
      'direction': direction,
      'timing': timing,
      'start_date': startDate,
      if (endDate != null && endDate!.isNotEmpty) 'end_date': endDate,
      'days_count': daysCount,
      'notes': notes,
      'children': children.map((c) => c.toJson()).toList(),
    };
  }
}

class SubscriptionChildRequest {
  final int childId;
  final String pickupAddressId;
  final String dropoffAddressId;
  final double pricePerChild;
  final String childNotes;

  SubscriptionChildRequest({
    required this.childId,
    required this.pickupAddressId,
    required this.dropoffAddressId,
    required this.pricePerChild,
    required this.childNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'child_id': childId,
      'pickup_address_id': int.tryParse(pickupAddressId) ?? 0,
      'dropoff_address_id': int.tryParse(dropoffAddressId) ?? 0,
      'price_per_child': pricePerChild,
      'child_notes': childNotes,
    };
  }
}
