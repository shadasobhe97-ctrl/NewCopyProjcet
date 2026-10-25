import 'dart:io';
import 'package:image_picker/image_picker.dart';
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
    await _cacheParentProfile(
      result.profile,
      fallbackFullName: fullName,
      fallbackPhoneNumber: phoneNumber,
      fallbackAvatarFile: avatarFile,
    );
    return result;
  }

  Future<void> cancelEmailChange() async {
    await remoteDataSource.cancelEmailChange();
  }

  Future<String> getEmailChangeStatus() async {
    return await remoteDataSource.getEmailChangeStatus();
  }

  Future<void> _cacheParentProfile(
    ParentModel parent, {
    String? fallbackFullName,
    String? fallbackPhoneNumber,
    dynamic fallbackAvatarFile,
  }) async {
    final localAvatarPath = (fallbackAvatarFile is XFile)
        ? fallbackAvatarFile.path
        : (fallbackAvatarFile is File
            ? fallbackAvatarFile.path
            : (fallbackAvatarFile is String ? fallbackAvatarFile : null));

    final rawAvatar = (parent.avatarUrl != null && parent.avatarUrl!.isNotEmpty)
        ? parent.avatarUrl
        : localAvatarPath;

    final versionedAvatar = (rawAvatar != null && rawAvatar.isNotEmpty)
        ? (rawAvatar.startsWith('http')
            ? '${rawAvatar.split('?v=').first}?v=${DateTime.now().millisecondsSinceEpoch}'
            : rawAvatar)
        : null;

    final effectiveFullName = parent.fullName.trim().isNotEmpty
        ? parent.fullName.trim()
        : ((fallbackFullName != null && fallbackFullName.trim().isNotEmpty)
            ? fallbackFullName.trim()
            : (sessionRepository.getFullName() ?? ''));

    final effectivePhoneNumber = parent.phoneNumber.trim().isNotEmpty
        ? parent.phoneNumber.trim()
        : ((fallbackPhoneNumber != null && fallbackPhoneNumber.trim().isNotEmpty)
            ? fallbackPhoneNumber.trim()
            : (sessionRepository.getPhoneNumber() ?? ''));

    await sessionRepository.saveUserSession(
      token: sessionRepository.getToken() ?? '',
      tokenType: 'Bearer',
      roleId: sessionRepository.getRoleId() ?? 7,
      roleName: 'parent',
      userId: parent.userId,
      fullName: effectiveFullName,
      phoneNumber: effectivePhoneNumber,
      isActive: sessionRepository.getIsActive() ?? true,
      avatarUrl: versionedAvatar,
    );
    await StorageService.saveFullName(effectiveFullName);
    await StorageService.savePhoneNumber(effectivePhoneNumber);
    if (versionedAvatar != null) {
      await sessionRepository.saveAvatarUrl(versionedAvatar);
      await StorageService.saveAvatarUrl(versionedAvatar);
    }
  }

  String getCachedFullName() => sessionRepository.getFullName() ?? '';
  String getCachedPhoneNumber() => sessionRepository.getPhoneNumber() ?? '';
  String? getCachedAvatarUrl() => sessionRepository.getAvatarUrl();
}

