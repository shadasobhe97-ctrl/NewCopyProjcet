class DriverCompleteProfileResponse {
  final bool status;
  final String message;
  final DriverProfileData? data;

  DriverCompleteProfileResponse({required this.status, required this.message, this.data});

  factory DriverCompleteProfileResponse.fromJson(Map<String, dynamic> json) {
    return DriverCompleteProfileResponse(
      status: _readBool(json['status']),
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map ? DriverProfileData.fromJson(Map<String, dynamic>.from(json['data'])) : null,
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
      id: _readInt(json['id']),
      accountId: _readInt(json['account_id']),
      fullName: json['full_name']?.toString() ?? '',
      driverStatus: json['driver_status']?.toString() ?? 'Pending',
    );
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

bool _readBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}
