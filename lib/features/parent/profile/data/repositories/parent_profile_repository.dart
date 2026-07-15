import 'package:kids_transport/core/services/storage_service.dart';
import '../datasources/parent_profile_remote_data_source.dart';
import '../models/parent_model.dart';

class ParentProfileRepository {
  final ParentProfileRemoteDataSource remoteDataSource;

  ParentProfileRepository({required this.remoteDataSource});

  /// جلب ملف ولي الأمر من الباك إند وحفظه في الكاش المحلي (Cache-First Support)
  Future<ParentModel> getParentProfile() async {
    final parent = await remoteDataSource.getParentProfile();
    await _cacheParentProfile(parent);
    return parent;
  }

  /// تحديث ملف ولي الأمر بالباك إند وحفظ التغيير في الكاش المحلي (API-First Strategy)
  Future<ParentModel> updateParentProfile({
    required String fullName,
    required String phoneNumber,
    String? email,
    String? alternativePhone,
  }) async {
    final parent = await remoteDataSource.updateParentProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
      alternativePhone: alternativePhone,
    );
    await _cacheParentProfile(parent);
    return parent;
  }

  Future<void> _cacheParentProfile(ParentModel parent) async {
    await StorageService.saveUserSession(
      token: StorageService.getToken() ?? '',
      tokenType: StorageService.getTokenType(),
      roleId: StorageService.getRoleId() ?? 3,
      roleName: StorageService.getRoleName(),
      userId: StorageService.getUserId(),
      fullName: parent.fullName,
      phoneNumber: parent.phoneNumber,
      isActive: StorageService.getIsActive(),
    );
  }

  String getCachedFullName() => StorageService.getFullName() ?? '';
  String getCachedPhoneNumber() => StorageService.getPhoneNumber() ?? '';
}
