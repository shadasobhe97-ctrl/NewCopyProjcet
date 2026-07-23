class SubscriptionCheckModel {
  final bool success;
  final bool hasSubscription;

  SubscriptionCheckModel({
    required this.success,
    required this.hasSubscription,
  });

  factory SubscriptionCheckModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionCheckModel(
      success: json['success'] as bool? ?? false,
      hasSubscription: json['has_subscription'] as bool? ?? false,
    );
  }
}
