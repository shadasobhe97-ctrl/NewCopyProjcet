import 'dart:io';
import 'package:kids_transport/features/auth/login/data/repositories/session_repository.dart';
import '../datasources/parent_profile_remote_data_source.dart';
import '../models/parent_model.dart';

class ParentProfileRepository {
  final ParentProfileRemoteDataSource remoteDataSource;
  final SessionRepository sessionRepository;

  ParentProfileRepository({
    required this.remoteDataSource,
    required this.sessionRepository,
  });

  /// جلب ملف ولي الأمر من الباك إند وحفظه في الكاش المحلي (Cache-First Support)
  Future<ParentModel> getParentProfile() async {
    final parent = await remoteDataSource.getParentProfile();
    await _cacheParentProfile(parent);
    return parent;
  }

  /// تحديث ملف ولي الأمر بالباك إند (مع صورة اختيارية) وحفظ التغيير محلياً
  Future<ParentModel> updateParentProfile({
    required String fullName,
    required String phoneNumber,
    String? email,
    String? alternativePhone,
    File? avatarFile,
  }) async {
    final parent = await remoteDataSource.updateParentProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
      alternativePhone: alternativePhone,
      avatarFile: avatarFile,
    );
    await _cacheParentProfile(parent);
    return parent;
  }

  Future<void> _cacheParentProfile(ParentModel parent) async {
    await sessionRepository.saveParentId(parent.parentId);
    await sessionRepository.saveUserSession(
      token: sessionRepository.getToken() ?? '',
      tokenType: 'Bearer',
      roleId: sessionRepository.getRoleId() ?? 3,
      roleName: 'parent',
      userId: int.tryParse(sessionRepository.getUserId() ?? '') ?? 0,
      fullName: parent.fullName,
      phoneNumber: parent.phoneNumber,
      isActive: sessionRepository.getIsActive() ?? true,
    );
  }

  String getCachedFullName() => sessionRepository.getFullName() ?? '';
  String getCachedPhoneNumber() => sessionRepository.getPhoneNumber() ?? '';
}
