class SubscriptionModel {
  final int id;
  final SubscriptionDriver driver;
  final List<SubscriptionChild> children;
  final int childrenCount;
  final String subscriptionType;
  final String status;
  final String createdAt;
  final String startDate;
  final String endDate;
  final double totalPrice;
  final String timing;
  final String direction;
  final String? notes;
  final String? rejectionReason;

  const SubscriptionModel({
    required this.id,
    required this.driver,
    required this.children,
    required this.childrenCount,
    required this.subscriptionType,
    required this.status,
    required this.createdAt,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.timing,
    required this.direction,
    this.notes,
    this.rejectionReason,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    var childrenList = json['children'] as List? ?? [];
    return SubscriptionModel(
      id: json['id'] as int? ?? 0,
      driver: SubscriptionDriver.fromJson(json['driver'] as Map<String, dynamic>? ?? {}),
      children: childrenList.map((e) => SubscriptionChild.fromJson(e as Map<String, dynamic>)).toList(),
      childrenCount: json['children_count'] as int? ?? childrenList.length,
      subscriptionType: json['subscription_type'] as String? ?? 'monthly',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      timing: json['timing'] as String? ?? '',
      direction: json['direction'] as String? ?? '',
      notes: json['notes'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver': driver.toJson(),
      'children': children.map((e) => e.toJson()).toList(),
      'children_count': childrenCount,
      'subscription_type': subscriptionType,
      'status': status,
      'created_at': createdAt,
      'start_date': startDate,
      'end_date': endDate,
      'total_price': totalPrice,
      'timing': timing,
      'direction': direction,
      'notes': notes,
      'rejection_reason': rejectionReason,
    };
  }
}

class SubscriptionDriver {
  final int id;
  final String? phone;
  final double rating;
  final SubscriptionUser user;

  const SubscriptionDriver({
    required this.id,
    this.phone,
    required this.rating,
    required this.user,
  });

  factory SubscriptionDriver.fromJson(Map<String, dynamic> json) {
    return SubscriptionDriver(
      id: json['id'] as int? ?? 0,
      phone: json['phone'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      user: SubscriptionUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (phone != null) 'phone': phone,
      'rating': rating,
      'user': user.toJson(),
    };
  }
}

class SubscriptionUser {
  final String fullName;
  final String? avatarUrl;

  const SubscriptionUser({
    required this.fullName,
    this.avatarUrl,
  });

  factory SubscriptionUser.fromJson(Map<String, dynamic> json) {
    return SubscriptionUser(
      fullName: json['full_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
  }
}

class SubscriptionChild {
  final int? id;
  final String fullName;
  final String? photoUrl;
  final String grade;
  final SubscriptionSchool school;

  const SubscriptionChild({
    this.id,
    required this.fullName,
    this.photoUrl,
    required this.grade,
    required this.school,
  });

  factory SubscriptionChild.fromJson(Map<String, dynamic> json) {
    return SubscriptionChild(
      id: json['id'] as int?,
      fullName: json['full_name'] as String? ?? json['name'] as String? ?? '',
      photoUrl: json['photo_url'] as String? ?? json['image'] as String?,
      grade: (json['grade'] ?? json['grade_level'] ?? 'ابتدائي').toString(),
      school: SubscriptionSchool.fromJson(json['school'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'full_name': fullName,
      if (photoUrl != null) 'photo_url': photoUrl,
      'grade': grade,
      'school': school.toJson(),
    };
  }
}

class SubscriptionSchool {
  final String name;

  const SubscriptionSchool({
    required this.name,
  });

  factory SubscriptionSchool.fromJson(Map<String, dynamic> json) {
    return SubscriptionSchool(
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
