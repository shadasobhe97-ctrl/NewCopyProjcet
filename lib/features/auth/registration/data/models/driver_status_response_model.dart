class DriverStatusResponseModel {
  final bool status;
  final bool isActive;
  final String driverStatus;
  final String? rejectionReason;
  final String? message;

  const DriverStatusResponseModel({
    required this.status,
    required this.isActive,
    required this.driverStatus,
    this.rejectionReason,
    this.message,
  });

  factory DriverStatusResponseModel.fromJson(Map<String, dynamic> json) {
    return DriverStatusResponseModel(
      status: json['status'] == true || json['status'] == 1,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      driverStatus: json['driver_status']?.toString() ?? 'Pending',
      rejectionReason: json['rejection_reason']?.toString(),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'is_active': isActive,
      'driver_status': driverStatus,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
      if (message != null) 'message': message,
    };
  }

  bool get isApproved => isActive || driverStatus.toLowerCase() == 'approved';
  bool get isPending => driverStatus.toLowerCase() == 'pending';
  bool get isRejected => driverStatus.toLowerCase() == 'rejected';
}
