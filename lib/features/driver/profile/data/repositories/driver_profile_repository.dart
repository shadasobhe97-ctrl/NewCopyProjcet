import 'dart:io';
import 'package:kids_transport/core/services/storage_service.dart';
import '../data_sources/driver_profile_remote_data_source.dart';
import '../models/driver_model.dart';

class DriverProfileRepository {
  final DriverProfileRemoteDataSource remoteDataSource;

  DriverProfileRepository({required this.remoteDataSource});

  /// جلب بيانات السائق من السيرفر وتحديث الكاش المحلي عند النجاح (Cache-First Support)
  Future<DriverModel> getDriverProfile() async {
    final driver = await remoteDataSource.getDriverProfile();
    
    // تحديث البيانات المحلية محلياً فور النجاح
    await StorageService.saveUserSession(
      token: StorageService.getToken() ?? '',
      tokenType: StorageService.getTokenType(),
      roleId: StorageService.getRoleId() ?? 4,
      roleName: StorageService.getRoleName(),
      userId: StorageService.getUserId(),
      fullName: driver.fullName,
      phoneNumber: driver.phoneNumber,
      isActive: StorageService.getIsActive(),
    );
    
    return driver;
  }

  /// تحديث بيانات السائق بالسيرفر وتحديث الكاش المحلي عند النجاح فقط (API-First Strategy)
  Future<DriverModel> updateProfile({
    required String fullName,
    required String phoneNumber,
    String? alternativePhone,
    String? email,
    File? avatarFile,
  }) async {
    final driver = await remoteDataSource.updateDriverProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      alternativePhone: alternativePhone,
      email: email,
      avatarFile: avatarFile,
    );

    // تحديث البيانات المحلية فقط عند نجاح الـ API بالكامل
    await StorageService.saveUserSession(
      token: StorageService.getToken() ?? '',
      tokenType: StorageService.getTokenType(),
      roleId: StorageService.getRoleId() ?? 4,
      roleName: StorageService.getRoleName(),
      userId: StorageService.getUserId(),
      fullName: driver.fullName,
      phoneNumber: driver.phoneNumber,
      isActive: StorageService.getIsActive(),
    );

    return driver;
  }
}
