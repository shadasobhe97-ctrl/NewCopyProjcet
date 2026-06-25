// ==========================================
// نموذج بيانات السائق
// TODO: عند الربط بالـ API، استبدل هذا النموذج بالبيانات القادمة من الـ Backend
// ==========================================

class DriverModel {
  final int id;
  final String fullName;
  final String phone;
  final String? avatarUrl; // TODO: رابط الصورة الحقيقية من الـ API
  final String status; // 'online' | 'offline'
  final VehicleInfo? vehicle;
  final VehicleInfo? backupVehicle; // المركبة الاحتياطية

  const DriverModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.avatarUrl,
    this.status = 'offline',
    this.vehicle,
    this.backupVehicle,
  });

  // TODO: استبدل هذه الدالة بـ fromJson تستقبل بيانات الـ API الحقيقية
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatar_url'],
      status: json['status'] ?? 'offline',
      vehicle:
          json['vehicle'] != null ? VehicleInfo.fromJson(json['vehicle']) : null,
      backupVehicle: json['backup_vehicle'] != null
          ? VehicleInfo.fromJson(json['backup_vehicle'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'status': status,
      'vehicle': vehicle?.toJson(),
      'backup_vehicle': backupVehicle?.toJson(),
    };
  }
}

// نموذج بيانات المركبة
class VehicleInfo {
  final String brand;
  final String model;
  final String plateNumber;
  final String color;
  final String type;
  final int year;
  final int capacity;
  final bool hasAc;
  final String? imageUrl; // TODO: رابط صورة المركبة من الـ API
  final String approvalStatus; // 'pending' | 'approved' | 'rejected'

  const VehicleInfo({
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.color,
    required this.type,
    required this.year,
    required this.capacity,
    this.hasAc = true,
    this.imageUrl,
    this.approvalStatus = 'approved',
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      plateNumber: json['plate_number'] ?? '',
      color: json['color'] ?? '',
      type: json['type'] ?? 'Bus',
      year: json['year'] ?? 2023,
      capacity: json['capacity'] ?? 14,
      hasAc: json['has_ac'] == 1 || json['has_ac'] == true,
      imageUrl: json['image_url'],
      approvalStatus: json['approval_status'] ?? 'approved',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'plate_number': plateNumber,
      'color': color,
      'type': type,
      'year': year,
      'capacity': capacity,
      'has_ac': hasAc ? 1 : 0,
      'image_url': imageUrl,
      'approval_status': approvalStatus,
    };
  }
}

// نموذج طلب اشتراك الطالب
class SubscriptionRequest {
  final int id;
  final String studentName;
  final String? studentAvatarUrl; // TODO: صورة الطالب من الـ API
  final String schoolName;
  final String tripPeriod; // 'morning' | 'evening' | 'both'
  final String address;
  final String district; // الحي

  const SubscriptionRequest({
    required this.id,
    required this.studentName,
    this.studentAvatarUrl,
    required this.schoolName,
    required this.tripPeriod,
    required this.address,
    required this.district,
  });

  // TODO: استبدل هذه الدالة بـ fromJson تستقبل بيانات الـ API الحقيقية
  factory SubscriptionRequest.fromJson(Map<String, dynamic> json) {
    return SubscriptionRequest(
      id: json['id'] ?? 0,
      studentName: json['student_name'] ?? '',
      studentAvatarUrl: json['student_avatar_url'],
      schoolName: json['school_name'] ?? '',
      tripPeriod: json['trip_period'] ?? 'both',
      address: json['address'] ?? '',
      district: json['district'] ?? '',
    );
  }

  // نص الفترة بالعربي
  String get tripPeriodArabic {
    switch (tripPeriod) {
      case 'morning':
        return 'فترة صباحية فقط';
      case 'evening':
        return 'فترة مسائية فقط';
      case 'both':
        return 'الفترتين (صباحي ومسائي)';
      default:
        return 'غير محدد';
    }
  }
}
