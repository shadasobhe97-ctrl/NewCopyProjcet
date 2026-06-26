import '../data_sources/driver_remote_data_source.dart';
import '../data_sources/parent_remote_data_source.dart';
import '../models/driver_register_request.dart';
import '../models/driver_register_response.dart';
import '../models/driver_complete_profile_response.dart';
import '../models/parent_register_request.dart';
import '../models/parent_register_response.dart';

class DriverVerifyOtpResponse {
  final bool status;
  final String message;
  final int userId;
  final String accessToken;

  DriverVerifyOtpResponse({
    required this.status,
    required this.message,
    required this.userId,
    required this.accessToken,
  });

  factory DriverVerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return DriverVerifyOtpResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      userId: json['user_id'] ?? 0,
      accessToken: json['access_token'] ?? json['token'] ?? '',
    );
  }
}

class RegistrationRepository {
  final DriverRemoteDataSource _driverDataSource;
  final ParentRemoteDataSource _parentDataSource;

  RegistrationRepository({
    DriverRemoteDataSource? driverDataSource,
    ParentRemoteDataSource? parentDataSource,
  })  : _driverDataSource = driverDataSource ?? DriverRemoteDataSource(),
        _parentDataSource = parentDataSource ?? ParentRemoteDataSource();

  // ==================== Driver ====================

  Future<DriverRegisterResponse> registerDriver(DriverRegisterRequest request) async {
    final responseData = await _driverDataSource.register(request);
    return DriverRegisterResponse.fromJson(responseData);
  }

  Future<DriverVerifyOtpResponse> verifyDriverOtp(String email, String otpCode) async {
    final responseData = await _driverDataSource.verifyOtp(email, otpCode);
    return DriverVerifyOtpResponse.fromJson(responseData);
  }

  Future<DriverCompleteProfileResponse> completeDriverProfile({
    required int userId,
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final responseData = await _driverDataSource.completeProfile(
      userId: userId,
      token: token,
      data: data,
    );
    return DriverCompleteProfileResponse.fromJson(responseData);
  }

  // ==================== Parent ====================

  Future<Map<String, dynamic>> sendParentOtp(String email) async {
    return await _parentDataSource.sendOtp(email);
  }

  Future<ParentRegisterResponse> registerParent(ParentRegisterRequest request) async {
    final responseData = await _parentDataSource.register(request);
    return ParentRegisterResponse.fromJson(responseData);
  }

  Future<ParentAddressResponse> addParentAddress({
    required String token,
    required String label,
    required double lat,
    required double lng,
    required bool isDefault,
  }) async {
    final responseData = await _parentDataSource.addAddress(
      token: token,
      label: label,
      lat: lat,
      lng: lng,
      isDefault: isDefault,
    );
    return ParentAddressResponse.fromJson(responseData);
  }
}
