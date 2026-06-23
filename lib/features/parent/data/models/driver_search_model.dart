class DriverSearchModel {
  final String id;
  final String fullName;
  final String? photoUrl;
  final String gender;          // 'MALE' أو 'FEMALE' للفلترة حسب جنس السائق
  final double rating;          // التقييم (مثال: 4.9)
  final String vehicleType;     // نوع السيارة (باص، هونداي H1، إلخ)
  final int totalSeats;         // السعة الإجمالية للسيارة
  final int availableSeats;     // المقاعد الشاغرة الحالية (مهم جداً لفلترة عدد الأطفال)
  final List<String> serviceZones; // المناطق السكنية التي يغطيها السائق
  final String preferredTimeSlot; // 'MORNING', 'EVENING', 'BOTH'
  
  // بيانات إضافية تظهر داخل بروفايل السائق فقط
  final String? phoneNumber;
  final bool isLicenseVerified;
  final bool isCriminalRecordVerified;

  DriverSearchModel({
    required this.id,
    required this.fullName,
    this.photoUrl,
    required this.gender,
    required this.rating,
    required this.vehicleType,
    required this.totalSeats,
    required this.availableSeats,
    required this.serviceZones,
    required this.preferredTimeSlot,
    this.phoneNumber,
    this.isLicenseVerified = false,
    this.isCriminalRecordVerified = false,
  });

  factory DriverSearchModel.fromJson(Map<String, dynamic> json) {
    return DriverSearchModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      photoUrl: json['photo_url'],
      gender: json['gender'] ?? 'MALE',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      vehicleType: json['vehicle_type'] ?? '',
      totalSeats: json['total_seats'] ?? 0,
      availableSeats: json['available_seats'] ?? 0,
      serviceZones: List<String>.from(json['service_zones'] ?? []),
      preferredTimeSlot: json['preferred_time_slot'] ?? 'BOTH',
      phoneNumber: json['phone_number'],
      isLicenseVerified: json['is_license_verified'] ?? false,
      isCriminalRecordVerified: json['is_criminal_verified'] ?? false,
    );
  }
}