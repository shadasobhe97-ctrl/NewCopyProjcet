// نموذج طلب الاشتراك - GET /api/parent/requests
// Response fields match SubscriptionModel (نفس الريسبونس)
class RequestModel {
  final int id;
  final String subscriptionType; // monthly | weekly | daily
  final String direction;        // both | to_school | from_school
  final String timing;           // MORNING | AFTERNOON
  final String startDate;
  final String? endDate;
  final double totalPrice;
  final String status;           // pending | accepted | rejected | cancelled
  final String? statusAr;
  final String? pickupTime;
  final String? dropoffTime;
  final String createdAt;
  final RequestDriver driver;
  final RequestSchool school;
  final List<RequestChild> children;
  final RequestContract? contract;
  final String? rejectionReason;

  const RequestModel({
    required this.id,
    required this.subscriptionType,
    required this.direction,
    required this.timing,
    required this.startDate,
    this.endDate,
    required this.totalPrice,
    required this.status,
    this.statusAr,
    this.pickupTime,
    this.dropoffTime,
    required this.createdAt,
    required this.driver,
    required this.school,
    required this.children,
    this.contract,
    this.rejectionReason,
  });

  int get childrenCount => children.length;

  String get statusDisplayLabel {
    if (statusAr != null && statusAr!.isNotEmpty) return statusAr!;
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'pending':
        return 'قيد الانتظار';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  String get childrenNames {
    return children.map((c) => c.name).join('، ');
  }

  String get formattedPrice {
    return '${totalPrice.toInt()} د.ل';
  }

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: _parseInt(json['id']) ?? 0,
      subscriptionType: json['subscription_type']?.toString() ?? 'monthly',
      direction: json['direction']?.toString() ?? '',
      timing: json['timing']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString(),
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      statusAr: json['status_ar']?.toString(),
      pickupTime: json['pickup_time']?.toString(),
      dropoffTime: json['dropoff_time']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      driver: RequestDriver.fromJson(
        json['driver'] as Map<String, dynamic>? ?? {},
      ),
      school: RequestSchool.fromJson(
        json['school'] as Map<String, dynamic>? ?? {},
      ),
      children: (json['children'] as List<dynamic>? ?? [])
          .map((e) => RequestChild.fromJson(e as Map<String, dynamic>))
          .toList(),
      contract: json['contract'] is Map
          ? RequestContract.fromJson(
              Map<String, dynamic>.from(json['contract'] as Map))
          : null,
      rejectionReason: json['rejection_reason']?.toString(),
    );
  }

  static int? _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subscription_type': subscriptionType,
        'direction': direction,
        'timing': timing,
        'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        'total_price': totalPrice,
        'status': status,
        if (statusAr != null) 'status_ar': statusAr,
        if (pickupTime != null) 'pickup_time': pickupTime,
        if (dropoffTime != null) 'dropoff_time': dropoffTime,
        'created_at': createdAt,
        'driver': driver.toJson(),
        'school': school.toJson(),
        'children': children.map((c) => c.toJson()).toList(),
        if (contract != null) 'contract': contract!.toJson(),
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      };
}

// ── السائق ──
class RequestDriver {
  final int id;
  final String name;
  final String? phone;

  const RequestDriver({
    required this.id,
    required this.name,
    this.phone,
  });

  factory RequestDriver.fromJson(Map<String, dynamic> json) => RequestDriver(
        id: json['id'] as int? ?? 0,
        name: json['name']?.toString() ?? json['full_name']?.toString() ?? '',
        phone: json['phone']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (phone != null) 'phone': phone,
      };
}

// ── المدرسة ──
class RequestSchool {
  final int id;
  final String name;

  const RequestSchool({required this.id, required this.name});

  factory RequestSchool.fromJson(Map<String, dynamic> json) => RequestSchool(
        id: json['id'] as int? ?? 0,
        name: json['name']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

// ── الطفل ──
class RequestChild {
  final int? id;
  final String name;
  final String? schoolName;
  final double? pricePerChild;

  const RequestChild({
    this.id,
    required this.name,
    this.schoolName,
    this.pricePerChild,
  });

  factory RequestChild.fromJson(Map<String, dynamic> json) => RequestChild(
        id: json['id'] as int?,
        name: json['name']?.toString() ?? '',
        schoolName: json['school_name']?.toString(),
        pricePerChild: (json['price_per_child'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        if (schoolName != null) 'school_name': schoolName,
        if (pricePerChild != null) 'price_per_child': pricePerChild,
      };
}

// ── العقد ──
class RequestContract {
  final int id;
  final String contractNumber;
  final String? pdfUrl;

  const RequestContract({
    required this.id,
    required this.contractNumber,
    this.pdfUrl,
  });

  factory RequestContract.fromJson(Map<String, dynamic> json) =>
      RequestContract(
        id: json['id'] as int? ?? 0,
        contractNumber: json['contract_number']?.toString() ?? '',
        pdfUrl: json['pdf_url']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'contract_number': contractNumber,
        if (pdfUrl != null) 'pdf_url': pdfUrl,
      };
}
