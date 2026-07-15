import 'dart:io';
import 'package:kids_transport/features/auth/login/data/repositories/session_repository.dart';
import '../data_sources/driver_profile_remote_data_source.dart';
import '../models/driver_model.dart';

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

  String getCachedFullName() => sessionRepository.getFullName() ?? '';
  String getCachedPhoneNumber() => sessionRepository.getPhoneNumber() ?? '';
}
