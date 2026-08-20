import 'dart:io';
import 'package:kids_transport/core/models/email_verification_info.dart';
import 'package:kids_transport/features/auth/login/data/repositories/session_repository.dart';
import '../data_sources/driver_profile_remote_data_source.dart';
import '../models/driver_model.dart';
import '../models/driver_legal_data_model.dart';

class DriverProfileRepository {
  final DriverProfileRemoteDataSource remoteDataSource;
  final SessionRepository sessionRepository;

  DriverProfileRepository({
    required this.remoteDataSource,
    required this.sessionRepository,
  });

  /// جلب بيانات السائق من السيرفر وتحديث الكاش المحلي عند النجاح (Cache-First Support)
  Future<DriverModel> getDriverProfile() async {
    final driver = await remoteDataSource.getDriverProfile();
    
    // تحديث البيانات المحلية محلياً فور النجاح
    await sessionRepository.saveUserSession(
      token: sessionRepository.getToken() ?? '',
      tokenType: 'Bearer',
      roleId: sessionRepository.getRoleId() ?? 4,
      roleName: 'driver',
      userId: int.tryParse(sessionRepository.getUserId() ?? '') ?? 0,
      fullName: driver.fullName,
      phoneNumber: driver.phoneNumber,
      isActive: sessionRepository.getIsActive() ?? true,
    );
    
    return driver;
  }

  /// تحديث بيانات السائق بالسيرفر وتحديث الكاش المحلي عند النجاح فقط (API-First Strategy)
  Future<ProfileUpdateResult<DriverModel>> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? alternativePhone,
    String? email,
    File? avatarFile,
  }) async {
    final result = await remoteDataSource.updateDriverProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      alternativePhone: alternativePhone,
      email: email,
      avatarFile: avatarFile,
    );

    final driver = result.profile;
    // تحديث البيانات المحلية فقط عند نجاح الـ API بالكامل
    await sessionRepository.saveUserSession(
      token: sessionRepository.getToken() ?? '',
      tokenType: 'Bearer',
      roleId: sessionRepository.getRoleId() ?? driver.roleId,
      roleName: 'driver',
      userId: driver.userId > 0 ? driver.userId : (int.tryParse(sessionRepository.getUserId() ?? '') ?? 0),
      fullName: driver.fullName.isNotEmpty ? driver.fullName : (sessionRepository.getFullName() ?? ''),
      phoneNumber: driver.phoneNumber.isNotEmpty ? driver.phoneNumber : (sessionRepository.getPhoneNumber() ?? ''),
      isActive: driver.isActive,
    );

    return result;
  }

  Future<void> cancelEmailChange() async {
    await remoteDataSource.cancelEmailChange();
  }

  Future<String> getEmailChangeStatus() async {
    return await remoteDataSource.getEmailChangeStatus();
  }

  Future<DriverLegalDataModel> getLegalData() async {
    return await remoteDataSource.getLegalData();
  }

  Future<DriverLegalDataModel> updateLegalData({
    String? nationalId,
    String? licenseNumber,
    String? licenseExpiry,
    String? insuranceExpiry,
    Map<String, File>? newFiles,
  }) async {
    return await remoteDataSource.updateLegalData(
      nationalId: nationalId,
      licenseNumber: licenseNumber,
      licenseExpiry: licenseExpiry,
      insuranceExpiry: insuranceExpiry,
      newFiles: newFiles,
    );
  }

  String getCachedFullName() => sessionRepository.getFullName() ?? '';
  String getCachedPhoneNumber() => sessionRepository.getPhoneNumber() ?? '';
}
