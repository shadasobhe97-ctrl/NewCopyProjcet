// نموذج طلب الاشتراك - GET /api/guardian/requests
class RequestModel {
  final int id;
  final String studentName;
  final String requestType;
  final String status; // pending | accepted | rejected | cancelled
  final String? statusLabel;
  final String createdAt;
  final String updatedAt;
  // حقول التفاصيل (تُعبأ عند جلب طلب محدد)
  final String? studentNationalId;
  final RequestGuardian? guardian;
  final RequestDetails? details;
  final String? rejectionReason;
  final String? cancelReason;

  const RequestModel({
    required this.id,
    required this.studentName,
    required this.requestType,
    required this.status,
    this.statusLabel,
    required this.createdAt,
    required this.updatedAt,
    this.studentNationalId,
    this.guardian,
    this.details,
    this.rejectionReason,
    this.cancelReason,
  });

  /// تحويل الـ status إلى نص عربي
  String get statusDisplayLabel {
    if (statusLabel != null && statusLabel!.isNotEmpty) return statusLabel!;
    switch (status.toLowerCase()) {
      case 'pending':
        return 'معلق';
      case 'accepted':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: _parseInt(json['id']) ?? 0,
      studentName:
          json['studentName']?.toString() ??
          json['student_name']?.toString() ??
          '',
      requestType:
          json['requestType']?.toString() ??
          json['request_type']?.toString() ??
          '',
      status: json['status']?.toString() ?? 'pending',
      statusLabel:
          json['statusLabel']?.toString() ?? json['status_label']?.toString(),
      createdAt:
          json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '',
      updatedAt:
          json['updatedAt']?.toString() ?? json['updated_at']?.toString() ?? '',
      studentNationalId:
          json['studentNationalId']?.toString() ??
          json['student_national_id']?.toString(),
      guardian: json['guardian'] is Map
          ? RequestGuardian.fromJson(
              Map<String, dynamic>.from(json['guardian'] as Map),
            )
          : null,
      details: json['details'] is Map
          ? RequestDetails.fromJson(
              Map<String, dynamic>.from(json['details'] as Map),
            )
          : null,
      rejectionReason:
          json['rejectionReason']?.toString() ??
          json['rejection_reason']?.toString(),
      cancelReason:
          json['cancelReason']?.toString() ??
          json['cancel_reason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentName': studentName,
      'requestType': requestType,
      'status': status,
      if (statusLabel != null) 'statusLabel': statusLabel,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (studentNationalId != null) 'studentNationalId': studentNationalId,
      if (guardian != null) 'guardian': guardian!.toJson(),
      if (details != null) 'details': details!.toJson(),
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (cancelReason != null) 'cancelReason': cancelReason,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

class RequestGuardian {
  final int id;
  final String name;
  final String phone;

  const RequestGuardian({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory RequestGuardian.fromJson(Map<String, dynamic> json) {
    return RequestGuardian(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'phone': phone};
}

class RequestDetails {
  final String? schoolName;
  final String? grade;
  final String? notes;

  const RequestDetails({this.schoolName, this.grade, this.notes});

  factory RequestDetails.fromJson(Map<String, dynamic> json) {
    return RequestDetails(
      schoolName:
          json['schoolName']?.toString() ?? json['school_name']?.toString(),
      grade: json['grade']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (schoolName != null) 'schoolName': schoolName,
      if (grade != null) 'grade': grade,
      if (notes != null) 'notes': notes,
    };
  }
}
