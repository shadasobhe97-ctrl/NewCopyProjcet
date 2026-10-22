import 'package:kids_transport/core/models/email_verification_info.dart';
import 'package:kids_transport/core/services/storage_service.dart';
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
  Future<ProfileUpdateResult<ParentModel>> updateParentProfile({
    required String fullName,
    required String phoneNumber,
    String? email,
    String? alternativePhone,
    dynamic avatarFile,
    bool removeAvatar = false,
  }) async {
    final result = await remoteDataSource.updateParentProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
      alternativePhone: alternativePhone,
      avatarFile: avatarFile,
      removeAvatar: removeAvatar,
    );

    if (removeAvatar) {
      await sessionRepository.saveAvatarUrl(null);
      await StorageService.saveAvatarUrl(null);
    }
    await _cacheParentProfile(result.profile);
    return result;
  }

  Future<void> cancelEmailChange() async {
    await remoteDataSource.cancelEmailChange();
  }

  Future<String> getEmailChangeStatus() async {
    return await remoteDataSource.getEmailChangeStatus();
  }

  Future<void> _cacheParentProfile(ParentModel parent) async {
    final versionedAvatar =
        (parent.avatarUrl != null && parent.avatarUrl!.isNotEmpty)
            ? '${parent.avatarUrl}?v=${DateTime.now().millisecondsSinceEpoch}'
            : null;

    await sessionRepository.saveUserSession(
      token: sessionRepository.getToken() ?? '',
      tokenType: 'Bearer',
      roleId: sessionRepository.getRoleId() ?? 7,
      roleName: 'parent',
      userId: parent.userId,
      fullName: parent.fullName,
      phoneNumber: parent.phoneNumber,
      isActive: sessionRepository.getIsActive() ?? true,
      avatarUrl: versionedAvatar,
    );
    await sessionRepository.saveAvatarUrl(versionedAvatar);
    await StorageService.saveAvatarUrl(versionedAvatar);
  }

  String getCachedFullName() => sessionRepository.getFullName() ?? '';
  String getCachedPhoneNumber() => sessionRepository.getPhoneNumber() ?? '';
  String? getCachedAvatarUrl() => sessionRepository.getAvatarUrl();
}

