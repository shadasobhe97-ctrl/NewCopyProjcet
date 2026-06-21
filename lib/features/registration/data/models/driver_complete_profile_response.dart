class DriverCompleteProfileResponse {
  final bool status;
  final String message;
  final DriverProfileData? data;

  DriverCompleteProfileResponse({required this.status, required this.message, this.data});

  factory DriverCompleteProfileResponse.fromJson(Map<String, dynamic> json) {
    return DriverCompleteProfileResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? DriverProfileData.fromJson(json['data']) : null,
    );
  }
}

class DriverProfileData {
  final int id;
  final int accountId;
  final String fullName;
  final String driverStatus; // حتكون "Pending"

  DriverProfileData({
    required this.id,
    required this.accountId,
    required this.fullName,
    required this.driverStatus,
  });

  factory DriverProfileData.fromJson(Map<String, dynamic> json) {
    return DriverProfileData(
      id: json['id'] ?? 0,
      accountId: json['account_id'] ?? 0,
      fullName: json['full_name'] ?? '',
      driverStatus: json['driver_status'] ?? 'Pending',
    );
  }
}